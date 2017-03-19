class AlertsController < ApplicationController
  before_action :set_source
  before_action :set_alert, only: [:edit, :update, :destroy]

  add_breadcrumb 'Data Sources', :data_sources_path
  before_action do
    add_breadcrumb @source.name, edit_data_source_path(@source)
    add_breadcrumb 'Alerts', data_source_alerts_path(@source)
  end

  def new
    @alert = Alert.new
    render_new
  end

  def create
    create_params = alert_params.merge(data_source_id: @source.id)
    @alert = Alert.create_for_data_source(create_params)
    if @alert.persisted?
      redirect_to data_source_alerts_path(@source)
    else
      render_new
    end
  end

  def index
    @alerts = @source.alerts.reorder(:created_at).load
  end

  def edit
    render_edit
  end

  def update
    if @alert.update(alert_params)
      redirect_to data_source_alerts_path(@source)
    else
      render_edit
    end
  end

  def destroy
    @alert.destroy
    redirect_to data_source_alerts_path(@source)
  end

  protected

  def set_source
    @source = DataSource.find(params[:data_source_id])
  end

  def set_alert
    data_source_alert = DataSourceAlert.find_by!(
      data_source_id: params[:data_source_id].to_i,
      alert_id: params[:id].to_i
    )
    @alert = data_source_alert.alert
  end

  def render_new
    add_breadcrumb 'Add Alert'
    render 'new'
  end

  def alert_params
    supported_rules = @source.class.supported_rules
    if supported_rules.none? { |rule_class| rule_class.name == params[:rule_type] }
      raise ArgumentError
    end
    alert_params = params.permit(:rule_type, :email, :message)
    alert_params[:rule_data] = params.require(:rule_data).permit!
    alert_params
  end

  def render_edit
    add_breadcrumb 'Edit Alert'
    render 'edit'
  end
end
