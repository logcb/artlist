flightplan = require "flightplan"
#
# flightplan = require "flightplan"

flightplan.target "production",
  host: "104.236.242.171" # "theartlist.ca"
  username: "core"
  agent: process.env.SSH_AUTH_SOCK
  readyTimeout: 30000

flightplan.target "staging",
  host: "artlist.website" # "104.236.246.144"
  username: "core"
  agent: process.env.SSH_AUTH_SOCK
  readyTimeout: 30000

artlist =
  repo: "https://github.com/logcb/artlist.git"
  branch: "deploy"
  commit: undefined

flightplan.remote ["reboot"], (remote) ->
  remote.sudo("reboot --force --reboot")

flightplan.remote ["setup"], (remote) ->
  remote.sudo("timedatectl set-timezone America/Montreal")
  remote.exec("timedatectl")

flightplan.remote ["setup"], (remote) ->
  remote.sudo("systemctl enable docker")

flightplan.remote ["status", "inspect", "default"], (remote) ->
  remote.exec "id"
  remote.exec "df /"
  remote.exec "docker images"
  remote.exec "docker ps --all"
  remote.exec "docker info"
  remote.exec "systemctl status artlist"

flightplan.remote "start", (remote) ->
  remote.sudo "systemctl start artlist"
  remote.exec "systemctl status artlist"

flightplan.remote "stop", (remote) ->
  remote.sudo "systemctl stop artlist"
  remote.exec "systemctl status artlist", failsafe: true

# `artlist.commit` is defined durring `deploy` and `build_image`.
# It is set to the latest commit in the deploy branch of `artlist.repo`.
flightplan.local ["deploy", "build_image"], (local) ->
  {stdout} = local.exec("git ls-remote #{artlist.repo} deploy", silent:yes)
  artlist.commit = stdout.split("\t")[0]
  local.log "artlist.commit is #{artlist.commit}"

flightplan.local ["deploy", "build_image"], (local) ->
  local.exec "cp secrets/theartlist.ca.secret.* artlist_image/"
  flightplan.writeDockerfile()
  local.log "Wrote artlist_image/Dockerfile to local filesystem."
  imageFiles = [
    "artlist_image/Dockerfile"
    "artlist_image/theartlist.ca.secret.key"
    "artlist_image/theartlist.ca.secret.txt"
  ]
  local.log "Transfering artlist_image files:", JSON.stringify(imageFiles)
  local.transfer imageFiles, "/home/core"

flightplan.remote ["deploy", "build_image"], (remote) ->
  remote.log "Building /home/core/artlist_image"
  remote.exec "docker build --tag artlist_image /home/core/artlist_image"
  remote.exec "docker images"
  remote.log "Removing build files"
  remote.exec "rm -rf artlist_image"

flightplan.remote ["deploy", "setup_storage_folder"], (remote) ->
  remote.exec "mkdir -p artlist_storage"

flightplan.local ["deploy", "setup_service"], (local) ->
  local.log "Transfering artlist.service unit file"
  local.transfer "artlist.service", "/home/core"

flightplan.remote ["deploy", "setup_service"], (remote) ->
  remote.log "Linking artlist service with systemd"
  remote.sudo "systemctl link /home/core/artlist.service"
  remote.sudo "systemctl enable /home/core/artlist.service"

flightplan.remote ["deploy", "restart"], (remote) ->
  remote.sudo("systemctl stop artlist")
  remote.sudo("systemctl start artlist")
  remote.exec("systemctl status artlist")

flightplan.remote ["erase"], (remote) ->
  remote.sudo("rm -rf artlist")
  remote.sudo("rm -rf artlist_image")
  remote.exec("rm -rf artlist.service")

flightplan.remote ["erase", "clean", "remove_expired_docker_containers"], (remote) ->
  expiredContainerList = remote.exec("docker ps --all | grep Exited", {failsafe:yes}).stdout
  if expiredContainerList
    containerIDs = (entry.split(" ")[0] for entry in expiredContainerList.trim().split("\n")).join(" ")
    remote.log "Removing containers:", containerIDs
    remote.exec "docker rm #{containerIDs}"
  else
    remote.log "No expired docker containers."

flightplan.remote ["erase", "clean", "remove_expired_docker_images"], (remote) ->
  expiredImageList = remote.exec("docker images | grep '^<none>' | awk '{print $3}'", failsafe:yes).stdout
  if expiredImageList
    expiredImageIDs = (id for id in expiredImageList.trim().split("\n")).join(" ")
    console.info expiredImageIDs
    remote.log "Removing containers:", expiredImageIDs
    remote.exec("docker rmi #{expiredImageIDs}")
  else
    remote.log "No expired docker images."

# Writes a Dockerfile to the local file system replacing placeholders defined in Dockerfile.template.
flightplan.writeDockerfile = ->
  {readFileSync, writeFileSync} = require "fs"
  dockerfile = readFileSync "Dockerfile.template", "utf-8"
  dockerfile = dockerfile.replace /ARTLIST_REPO/g, artlist.repo
  dockerfile = dockerfile.replace /ARTLIST_COMMIT/g, artlist.commit
  dockerfile = dockerfile.replace /ARTLIST_BRANCH/g, artlist.branch
  dockerfile = dockerfile.replace /COMMENT/, "This Dockerfile was generated by #{flightplan.target.task} task on #{(new Date).toJSON()}"
  writeFileSync "artlist_image/Dockerfile", dockerfile, "utf-8"
