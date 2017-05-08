# Congenial Enigma will support incoming data from multiple services, for
# example, ODK and DHIS2. When creating an integration, users tell us, among
# other information:
#
#   1. The service from which the incoming data originates (for example, ODK or
#      DHIS2)
#   2. What account or configuration to use for that service (for example, a
#      particular ODK Aggregate server)
#
# A ConfiguredService record encapsulates (2) above: it represents a fully
# configured service. The primary role of the configured service is to store
# credentials or otherwise provide a connection to the service. For example, if
# ODK is the service, a particular ODK Aggregate server is the configured
# service.
#
# A single configured service may have multiple data sources. For example, a
# single ODK Aggregate server may house multiple forms. The DataSource model
# determines how to actually process incoming data: the ConfiguredService model
# simply lays the foundation for DataSource.
#
# Depending on the context, the term "service" may refer either to the service
# itself -- also known as the "service technology" -- or to the configured
# service. Each ConfiguredService record is a configured service, not a service
# technology. However, ConfiguredService uses single table inheritance, and
# there is a different ConfiguredService subclass for each service technology.
# Subclasses also define class methods that return information about the service
# technology.
#
class ConfiguredService < ApplicationRecord
  include ModelAttributes::Name
  include ConfiguredService::Type
end
