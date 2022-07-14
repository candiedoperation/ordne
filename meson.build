# Project name, programming language and version
project (
    'com.github.candiedoperation.ordne',
    'c', 'vala',
    version: '1.0.2'
)

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

# Listing dependencies
dependencies = [
    dependency ('gtk+-3.0'),
    dependency ('granite'),
    dependency ('libhandy-1'),
    dependency ('libcanberra')
]

# Define executable
executable(
    meson.project_name (),
    'src/Application.vala',
    dependencies: dependencies,
    install: true
)

subdir ('data')
subdir ('po')

meson.add_install_script ('meson/post_install.py')
