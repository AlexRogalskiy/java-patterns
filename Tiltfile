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

load('ext://namespace', 'namespace_create', 'namespace_inject')
namespace_create('webapp')

conftest(path='k8s/backend/deployment.yaml', namespace='main')
# k8s_yaml('k8s/backend/deployment.yaml')
k8s_yaml(namespace_inject(read_file('k8s/backend/deployment.yaml'), 'webapp'), allow_duplicates=False)
k8s_resource('backend-java-patterns-v1', port_forwards=8000, resource_deps=['deploy', 'conftest'])

# Records the current time, then kicks off a server update.
# Normally, you would let Tilt do deploys automatically, but this
# shows you how to set up a custom workflow that measures it.
local_resource(
    'deploy',
    'python3 ./record-start-time.py'
)

# Add a live_update rule to our docker_build
congrats = "🎉 Congrats, you ran a live_update! 🎉"
docker_build('styled-java-patterns', '.', build_args={'IMAGE_SOURCE': 'node', 'IMAGE_TAG': '12-buster'},
    dockerfile='./Dockerfile',
    live_update=[
        sync('.', '/usr/src/app'),
        run('python3 ./record-start-time.py'),
        run('cd /usr/src/app/docs && pip3.8 install -r requirements.txt --quiet', trigger='./requirements.txt')
])
