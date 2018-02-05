# Pull the base image with given version.
ARG BUILD_TERRAFORM_VERSION="0.11.1"
FROM microsoft/terraform-test:${BUILD_TERRAFORM_VERSION}

ARG MODULE_NAME="terraform-azurerm-compute"

# Declare default build configurations for terraform.
ARG BUILD_ARM_SUBSCRIPTION_ID=""
ARG BUILD_ARM_CLIENT_ID=""
ARG BUILD_ARM_CLIENT_SECRET=""
ARG BUILD_ARM_TENANT_ID=""
ARG BUILD_ARM_TEST_LOCATION="WestEurope"
ARG BUILD_ARM_TEST_LOCATION_ALT="WestUS"

# Set environment variables for terraform runtime.
ENV ARM_SUBSCRIPTION_ID=${BUILD_ARM_SUBSCRIPTION_ID}
ENV ARM_CLIENT_ID=${BUILD_ARM_CLIENT_ID}
ENV ARM_CLIENT_SECRET=${BUILD_ARM_CLIENT_SECRET}
ENV ARM_TENANT_ID=${BUILD_ARM_TENANT_ID}
ENV ARM_TEST_LOCATION=${BUILD_ARM_TEST_LOCATION}
ENV ARM_TEST_LOCATION_ALT=${BUILD_ARM_TEST_LOCATION_ALT}

RUN mkdir /usr/src/${MODULE_NAME}
COPY . /usr/src/${MODULE_NAME}

RUN ssh-keygen -q -t rsa -b 4096 -f $HOME/.ssh/id_rsa

WORKDIR /usr/src/${MODULE_NAME}
RUN ["bundle", "install", "--gemfile", "./Gemfile"]
