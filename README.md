![Ordne Logo](https://raw.githubusercontent.com/candiedoperation/ordne/master/data/icons/64.svg) 
# Ordne
A Simple Pomodoro Timer

|![Screenshot from 2021-06-06 15 43 21](https://user-images.githubusercontent.com/47198395/120920796-4655ce80-c6de-11eb-9fc4-858e660480ae.png)|![Screenshot from 2021-06-06 15 44 07](https://user-images.githubusercontent.com/47198395/120920808-5a013500-c6de-11eb-93a7-ab066933bea2.png)|
| ------------- | ------------- |
| ![Screenshot from 2021-06-06 19 51 41](https://user-images.githubusercontent.com/47198395/120928044-b9703c80-c700-11eb-803b-499af42fbafb.png)|![Screenshot from 2021-06-06 19 51 21](https://user-images.githubusercontent.com/47198395/120928060-c5f49500-c700-11eb-8543-1b55fb738600.png)|
| ![Screenshot from 2021-06-06 19 51 39](https://user-images.githubusercontent.com/47198395/120928110-f0dee900-c700-11eb-8a91-390a349ac88c.png)| ![Screenshot from 2021-06-06 19 51 25](https://user-images.githubusercontent.com/47198395/120928119-fb997e00-c700-11eb-9da4-634224a8dd9e.png) |

## Building, Testing, and Installation

You'll need the following dependencies:

* gtk+-3.0
* granite
* libhandy-1
* valac

Above Dependencies get auto installed on `sudo apt-get install elementary-sdk`

Run `meson build` to configure the build environment.

    meson build --prefix=/usr
    cd build

To install, use `ninja install`, then execute with `com.github.candiedoperation.ordne`

    sudo ninja install
    com.github.candiedoperation.ordne
