# Congenial Enigma will support data received from multiple services -- for
# example, ODK and DHIS2 -- as well as data received from multiple destinations,
# for example, Gmail and Twilio. When creating an integration, users tell us,
# among other information:
#
#   1. The service from which data is sent (for example, ODK or DHIS2)
#   2. What account or configuration to use for that service (for example, a
#      particular ODK Aggregate server)
#   3. The service that receives the data (for example, Gmail or Twilio)
#   4. What account or configuration to use for this second service (for
#      example, a particular Gmail account)
#
# A ConfiguredService record encapsulates categories (2) and (4) above: it
# represents a fully configured service, whether that service is a data source
# provider, a data destination provider, or both. The primary role of the
# configured service is to store credentials or otherwise provide a connection
# to a service. For example, if ODK is the service, a particular ODK Aggregate
# server is the configured service.
#
# A single configured service may have multiple data sources. For example, a
# single ODK Aggregate server may house multiple forms. The DataSource model
# determines how to actually process incoming data: the ConfiguredService model
# simply lays the foundation for DataSource.
#
# Likewise, a single configured service may have multiple data destinations. A
# service may also be both a data source provider and a data destination
# provider.
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
