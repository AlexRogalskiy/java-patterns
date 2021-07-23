# -*- mode: Python -*

# For more on Extensions, see: https://docs.tilt.dev/extensions.html
load('ext://restart_process', 'docker_build_with_restart')

k8s_yaml('kubernetes.yaml')
k8s_resource('example-java-patterns', port_forwards=8000, resource_deps=['deploy'])

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
