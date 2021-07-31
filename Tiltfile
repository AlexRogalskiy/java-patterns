# -*- mode: Python -*

# For more on Extensions, see: https://docs.tilt.dev/extensions.html
load('ext://restart_process', 'docker_build_with_restart')
load('ext://conftest', 'conftest')
load('ext://list_port_forwards', 'display_port_forwards')
load('ext://print_tiltfile_dir', 'print_tiltfile_dir')
load('ext://min_tilt_version', 'min_tilt_version')
min_tilt_version('0.13.0')

load('ext://tilt_inspector', 'tilt_inspector')
tilt_inspector()

#load('ext://min_k8s_version', 'min_k8s_version')
#min_k8s_version('1.21.1')

conftest(path='k8s/deployment.yaml', namespace='main')
k8s_yaml('k8s/deployment.yaml')
k8s_resource('java-patterns', port_forwards=8000, resource_deps=['deploy', 'conftest'])

# Records the current time, then kicks off a server update.
# Normally, you would let Tilt do deploys automatically, but this
# shows you how to set up a custom workflow that measures it.
local_resource(
    'deploy',
    'python3 ./record-start-time.py'
)

# Add a live_update rule to our docker_build
congrats = "🎉 Congrats, you ran a live_update! 🎉"
docker_build_with_restart('java-patterns', '.', build_args={'IMAGE_SOURCE': 'node', 'IMAGE_TAG': '12-buster'},
    dockerfile='./Dockerfile',
    entrypoint=['mkdocs', 'serve', '--verbose', '--dirtyreload'],
    live_update=[
        sync('.', '/usr/src/app'),
        run('python3 ./record-start-time.py'),
        run('cd /usr/src/app/docs && pip3.8 install -r requirements.txt --quiet', trigger='./requirements.txt')
])
