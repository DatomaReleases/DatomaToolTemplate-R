# Datoma's R-based tool template
This document will guide you to migrate your R tool to Datoma.

If forking this template, feel free to change your new repository's name to match your project's name.

## What can you find on this repository?
[**.gitignore**](/.gitignore): No need to modify this file, it will keep the project clean of unnecessary files.

[**datomaconfig.yml**](/datomaconfig.yml): You only need to modify the [`taskname`](/datomaconfig.yml#L16) parameter to suit your project. 
- Choose one of the possible architectures, depending on your project needs ([keep only x86 or arm64](/datomaconfig.yml#L3C3-L12C14), if unsure, keep x86) and delete the other.
- If your main R Markdown script has a name different than **"script.Rmd"**, change [line **19**](/datomaconfig.yml#L19) accordingly.
- If the folder where your code outputs the results file is not named "**results**", change [line **20**](/datomaconfig.yml#L20) accordingly.
- Keep in mind that the [in_file](/datomaconfig.yml#L25) parameter will be used later.

[**description.taskname.md**](/description.taskname.md): You need to modify this file's name and change "taskname" for the name you defined on the previous file ([line **16**](/datomaconfig.yml#L16)).
- Then, add a description and citation.

[**Dockerfile**](/Dockerfile): This file should be modified according to the needs of your tool. You can modify the base image and install additional dependencies. Please, refrain from removing the existing dependencies. Also, the name of your main Rmd script can be modified if you wish. If your project requires additional files, please copy them to the **/app/** directory as you can see on [line **81**](/Dockerfile#L81).
- To test that the project works, we recommend that you also copy an input file to the **/app/** directory.

[**install_jobrunner_and_run.sh**](/install_jobrunner_and_run.sh): This file should only be modified if you have to set some environment variables (as shown on the [line **7** example](/install_jobrunner_and_run.sh#L7)).
- While testing, you will need to comment [line 4](/install_jobrunner_and_run.sh#L4) and also change [line **9**](/install_jobrunner_and_run.sh#L9) for **python3.11 script.Rmd** or similar. This is because it won't work outside Datoma's infrastructure.

[**install_jobrunner.py**](/install_jobrunner.py): This file doesn't have to be modified.

[**layout.taskname.json**](/layout.taskname.json): This is the file used on Datoma's web to specify the parameters and attach the input files. Modify according to your project's needs.
- Please, modify the **filename**, replacing `taskname` for the same name you have already defined on [**datomaconfig.yml**](/datomaconfig.yml#L16).
- The [`key`](/layout.taskname.json#L24) parameter must be the same as the one on [**datomaconfig.yml**](/datomaconfig.yml#L25). 

[**script.Rmd**](/script.Rmd): This is a mere example.
- [Line **19**](/script.Rmd#L19) shows how to get the filename of the input file.
- [Line **29**](/script.Rmd#L29) shows how to get the value of a parameter.

## How to test?
1. Inside this template's folder, execute the command `docker build -t toolname .`
2. Then, run `docker run --rm toolname`
    - Alternatively, you can run `docker run --rm -it --entrypoint="bash" toolname` to run the container interactively.
        - You can execute your Rmd script with `taskset -c 0 R -e "rmarkdown::render('script.Rmd', params = list(first_parameter = 'test', input_file = '/app/test_file.txt'))"`
3. If you have any issue while in this process, you can contact us: `contact` at `datoma.cloud`
4. When your project is working, please undo all modifications made for testing purposes and forward the whole project to the Datoma team: `releases` at `datoma.cloud`
