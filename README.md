# README

Build a single box with Rails 4.1.6, Nginx, Unicorn and PostgreSQL using Ansible (1.8).
You can deploy multiple rails apps on the same box.

Moreover this project can create different stages:

- development on Vagrant
- testing on EC2)
- staging on EC2 *( Creation of vars/staging-env.yml using testing as model is required )*
- production on EC2 *( Creation of vars/production-env.yml using testing as model is required )*

## Requirments
- Ansible > 1.8 `brew install ansible`
- Vagrant <https://www.vagrantup.com> `brew install vagrant`
- VirtualBox <https://www.virtualbox.org> `brew install virtualbox`
- SSH private and public key generated <https://help.github.com/articles/generating-ssh-keys/>
- SSH key added to SSH Agent `ssh-add -K [path/to/private SSH key]` why SSH agent<https://developer.github.com/guides/using-ssh-agent-forwarding/>

## Install roles

Install all required Ansible roles using `Ansiblefile.yml` as a sort of Gemfile

    $ ansible-galaxy install -r requirements.yml

## Private keys

Create and download the private key in ~/.ec2/simple_app.pem
(e.g. eu-west-1 region <https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName>)

    chmod 400 ~/.ec2/simple_app.pem

N.B. The keypair *MUST*  has the same name of the project.
Otherwise you have to change on `testing-env.yml` the `instances_keypair` variable according to your keypair name

## AWS Keys
Copy or create and download your AWS keys there:

    "~/.ec2/aws-${APP_NAME}.keys

## Setup site.yml (main Ansible playbook)

Basically it means choose ruby version, and some basic database and unicorn configs.
If you need a ruby version greater than 2.1.4 you have to update ruby-build version

      rbenv_plugins:
        - name: ruby-build
          repo: "git://github.com/sstephenson/ruby-build.git"
          version: v20141027

Then you can provision your environment (development|testing|staging|production) specifying the app name

    $ ./provision.sh simple_app development

To test your infrastructure deploy my micro rails app example: <https://github.com/aboutlo/capistrano-template-rails-app>
