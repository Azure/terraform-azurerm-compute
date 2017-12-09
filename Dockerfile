FROM microsoft/terraform-test:0.11.1

ENV MODULE_NAME terraform-azurerm-compute

RUN mkdir /usr/src/${MODULE_NAME}
COPY . /usr/src/${MODULE_NAME}

WORKDIR /usr/src/${MODULE_NAME}
RUN ["bundle", "install", "--gemfile", "./Gemfile"]
