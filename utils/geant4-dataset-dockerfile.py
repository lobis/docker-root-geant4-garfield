#!/usr/bin/python3

def main():
    import subprocess
    import argparse

    parser = argparse.ArgumentParser(description="Generate Dockerfile from base dockerfile (input argument) adding Geant4 datasets as ENV variables")

    parser.add_argument("-i", "--image", help="name of the docker image to use as base (required)", required=True)
    parser.add_argument("-o", "--output", help="path of output Dockerfile (default=./Dockerfile)", default="Dockerfile")

    args = parser.parse_args()

    result = subprocess.run(f"docker --version".split(), stdout=subprocess.PIPE)
    version = result.stdout.decode('utf-8')
    print(version)

    docker_image = args.image
    result = subprocess.run(f"docker run {docker_image} geant4-config --datasets".split(), stdout=subprocess.PIPE)
    datasets = result.stdout.decode('utf-8')
    print(datasets)

    env_variables = dict()
    print(f"Geant4 datasets:")
    # datasets should be a multi-line string with 3 words per line (name, env var, path)
    for line in datasets.split("\n"):
        words = line.split()
        assert len(words) == 3
        dataset_env_variable = words[1]
        dataset_path = words[2]
        print(f"{dataset_env_variable}={dataset_path}")
        env_variables[dataset_env_variable] = dataset_path

    # Create Dockerfile (labels will be inherited)
    with open(args.output, "w") as f:
        f.write(f"FROM {docker_image}\n\n")
        for variable, value in env_variables.items():
            f.write(f"ENV {variable}={value}\n")
        # ENTRYPOINT and CMD will be preserved

if __name__ == "__main__":
    main()