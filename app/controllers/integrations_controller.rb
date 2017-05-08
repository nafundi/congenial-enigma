class IntegrationsController < ApplicationController
  add_breadcrumb 'My Integrations', :integrations_path, except: :index

  def index
    @source_alerts = DataSourceAlert.reorder(:created_at).load
    add_breadcrumb 'My Integrations' if @source_alerts.any?
  end

  def new
    @source_services = ConfiguredServices::Odk.order_by_name
    @sources = DataSources::Odk.order_by_name
    @destination_services = ConfiguredServices::Gmail.order_by_name
    @destinations = DataDestinations::Gmail.order_by_name
    @alert = Alert.new
    add_breadcrumb 'Add Integration'
  end

  def create
    Alert.create_for_data_source(integration_params)
    # TODO: Error handling.
    redirect_to integrations_path
  end

  def destroy
    Alert.find(params[:id]).destroy
    redirect_to integrations_path
  end

  private

  def integration_params
    source = DataSource.find(params[:data_source_id])
    supported_rules = source.class.supported_rules
    if supported_rules.none? { |rule_class| rule_class.name == params[:rule_type] }
      raise ArgumentError
    end
    integration_params = params.permit(:data_source_id, :data_destination_id,
                                       :rule_type, :message)
    integration_params[:rule_data] = params.require(:rule_data).permit!
    integration_params
  end
end
