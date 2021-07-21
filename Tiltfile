# -*- mode: Python -*

k8s_yaml('kubernetes.yaml')
k8s_resource('example-java-patterns', port_forwards=8000, resource_deps=['deploy'])

# Records the current time, then kicks off a server update.
# Normally, you would let Tilt do deploys automatically, but this
# shows you how to set up a custom workflow that measures it.
local_resource(
    'deploy',
    'npm --version > build.txt'
)

# Add a live_update rule to our docker_build
congrats = "🎉 Congrats, you ran a live_update! 🎉"
docker_build('java-patterns', '.', build_args={'IMAGE_SOURCE': 'node', 'IMAGE_TAG': '12-buster'},
    live_update=[
        sync('.', '/usr/src/app'),
        run('cd /usr/src/app/docs && pip3.8 install -r requirements.txt --quiet', trigger='./requirements.txt')
])
