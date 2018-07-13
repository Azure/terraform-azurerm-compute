# Pull the base image with given version.
ARG BUILD_TERRAFORM_VERSION="0.11.1"
FROM microsoft/terraform-test:${BUILD_TERRAFORM_VERSION}

ARG MODULE_NAME="terraform-azurerm-compute"

# Declare default build configurations for terraform.
ARG BUILD_ARM_SUBSCRIPTION_ID="85b3dbca-5974-4067-9669-67a141095a76"
ARG BUILD_ARM_CLIENT_ID="27419052-4753-4544-a684-ec356a9e5ec2"
ARG BUILD_ARM_CLIENT_SECRET="a67a709e-e595-40e0-812e-fe47342b4452"
ARG BUILD_ARM_TENANT_ID="72f988bf-86f1-41af-91ab-2d7cd011db47"
ARG BUILD_ARM_TEST_LOCATION="WestEurope"
ARG BUILD_ARM_TEST_LOCATION_ALT="WestUS"

# Set environment variables for terraform runtime.
ENV ARM_SUBSCRIPTION_ID=${BUILD_ARM_SUBSCRIPTION_ID}
ENV ARM_CLIENT_ID=${BUILD_ARM_CLIENT_ID}
ENV ARM_CLIENT_SECRET=${BUILD_ARM_CLIENT_SECRET}
ENV ARM_TENANT_ID=${BUILD_ARM_TENANT_ID}
ENV ARM_TEST_LOCATION=${BUILD_ARM_TEST_LOCATION}
ENV ARM_TEST_LOCATION_ALT=${BUILD_ARM_TEST_LOCATION_ALT}

# Set work directory and generate ssh key
RUN mkdir /usr/src/${MODULE_NAME}
COPY . /usr/src/${MODULE_NAME}
WORKDIR /usr/src/${MODULE_NAME}
RUN ssh-keygen -q -t rsa -b 4096 -f $HOME/.ssh/id_rsa

# Install new version of terraform and golang
RUN apt-get install -y unzip >/dev/null
RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip >/dev/null 2>&1
RUN unzip terraform_0.11.7_linux_amd64.zip >/dev/null
RUN wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz >/dev/null 2>&1
RUN tar -zxvf go1.9.2.linux-amd64.tar.gz -C /usr/local/ >/dev/null
RUN mv terraform /usr/local/bin

# Install required go packages
ENV GOPATH $HOME/terratest/ssh
ENV PATH /usr/local/go/bin:/usr/local/bin:/usr/bin
RUN /bin/bash -c "go get github.com/gruntwork-io/terratest/modules/ssh"
RUN /bin/bash -c "go get github.com/gruntwork-io/terratest/modules/retry"
RUN /bin/bash -c "go get github.com/gruntwork-io/terratest/modules/terraform"
RUN /bin/bash -c "go get github.com/gruntwork-io/terratest/modules/test-structure"

RUN ["bundle", "install", "--gemfile", "./Gemfile"]