namespace :iclient do

  desc "Notify a single inspection with indicating mission_id"
  task :notify_single, [:mission_id,:update_data] => [:environment] do |task, args|
    raise "must indicate a company inspection mission_id" unless args[:mission_id]
    not_logging!
    if args[:update_data] == "false"
      Iclient::Workflow::Inspection.new(mission_id: args[:mission_id], update_data: false).notify
    else
      Iclient::Workflow::Inspection.new(mission_id: args[:mission_id]).notify
    end

  end

  desc "Notify a single inspection with indicating mission_id"
  task :notify_single_id, [:id,:update_data] => [:environment] do |task, args|
    raise "must indicate a company inspection id" unless args[:id]
    not_logging!
    begin
      inspection = Iclient::Inspection.find(args[:id].to_i)
      if inspection
        if args[:update_data] == "false"
          Iclient::Workflow::Inspection.new(_id: inspection.id, update_data: false).notify
        else
          puts "Transmitir inspección #{inspection.id} patente: #{inspection.patent} mission_id: #{inspection.mission_id}"
          Iclient::Workflow::Inspection.new(_id: inspection.id).notify
        end
      end
    rescue => e
      puts "Error: #{e.message}"
    end
  end

  desc "Forcing to fail inspection from :requested, :precoordinated, :coordinated workflow steps"
  task :fail_inspection, [:id,:update_data] => [:environment] do |task, args|
    raise "must indicate a company inspection id" unless args[:id]
    not_logging!
    id = args[:id].to_i
    inspection = Iclient::Inspection.find(id)
    if inspection
      inspection.update(state: :disapproved, sub_state: :forced_failure)
      Iclient::Workflow::Inspection.new(_id: id, update_data: false).notify
    else
      puts "Mission #{args[:mission_id]} doesn't exists in integrator database" 
    end
  end

  desc "Update data for inspection"
  task :inspection_update_data, [:mission_id] => [:environment] do |task, args|
    raise "must indicate a company inspection mission_id" unless args[:mission_id]
    inspection = Iclient::Inspection.where(mission_id: args[:mission_id]).first
    if inspection
      inspection.update_data
    end
  end

  desc "Notify inspections"
  task notify: :environment do
    not_logging!
    inspections = Iclient::Inspection.where("workflow_step not in('resolved','failed','invalidated', 'discarded','paused')")
    if inspections.none?
      puts "\nWARNING: There isn't inspections for injections\n\n"
    else
      inspections.each do |inspection|
        Iclient::Workflow::Inspection.new(_id: inspection.id).notify
      end
    end
  end

 desc "Just update iclient state in inspection"
  task :update_iclient_state, [:id,:update_data] => [:environment] do |task, args|
    not_logging!
    raise "must indicate a company inspection id" unless args[:id]
    inspection = Iclient::Inspection.find(args[:id].to_i)
    inspection.update_iclient_state
    puts "Estado actualizado código: #{inspection.iclient_state} #{inspection.iclient_state_description}"
  end  

  desc "Update iclient state in company"
  task :update_iclient_state_in_company, [:id,:update_data] => [:environment] do |task, args|
    not_logging!
    raise "must indicate a company inspection id" unless args[:id]
    inspection = Iclient::Inspection.find(args[:id].to_i)
    inspection.update_iclient_state_in_company
    if inspection.iclient_state_updated_in_company
      puts "Estado actualizado código: #{inspection.iclient_state} #{inspection.iclient_state_description} #{inspection.iclient_state_rockeptin_matching}"
    end
  end  

  desc "Update multiple iclient states pending in company"
  task update_multiple_iclient_state_pending: :environment do
    not_logging!
    inspections = Iclient::Inspection.where(workflow_step: :resolved, successfully_notify: true, state: :approved, sub_state: :waiting_review, iclient_state: nil, iclient_state_updated_in_company: nil)
    inspections.each do |inspection|
      inspection.update_iclient_state_in_company
      if inspection.iclient_state_updated_in_company
        puts "#{inspection.mission_id} (#{inspection.patent}) Estado actualizado código: #{inspection.iclient_state} #{inspection.iclient_state_description} #{inspection.iclient_state_rockeptin_matching}"
      else
        puts "#{inspection.mission_id} (#{inspection.patent}) NO SE ACTUALIZÓ EN COMPANY"
      end
    end
  end  

  desc "Update multiple iclient states pending in company"
  task update_multiple_iclient_state_failed: :environment do
    not_logging!
    inspections = Iclient::Inspection.where(iclient_state: 'F')
    inspections.each do |inspection|
      inspection.update_iclient_state_in_company
      if inspection.iclient_state_updated_in_company
        puts "#{inspection.mission_id} (#{inspection.patent}) Estado actualizado código: #{inspection.iclient_state} #{inspection.iclient_state_description} #{inspection.iclient_state_rockeptin_matching}"
      else
        puts "#{inspection.mission_id} (#{inspection.patent}) Estado actualizado código: #{inspection.iclient_state} (NO SE ACTUALIZÓ EN COMPANY)"
      end
    end
  end

  desc "Retry for Iclient state '3' => 'PENDIENTE POR SUSCRIPCION' "
  task retry_suscription_pending: :environment do
    not_logging!
    inspections = Iclient::Inspection.where(iclient_state: '3')
    if inspections.none?
      puts "\nWARNING: There isn't inspections in 'PENDIENTE POR SUSCRIPCION' \n\n"
    else
      inspections.each do |inspection|
        current_iclient_state = inspection.iclient_state
        puts "Inspección: #{inspection.mission_id} #{inspection.patent}"
        inspection.update_iclient_state_in_company
        inspection.reload
        if inspection.iclient_state != current_iclient_state
          puts "estado a actualizado a: #{inspection.iclient_state} #{inspection.iclient_state_description}"
        end
        puts "---------------------\n"
      end
    end
  end


  desc "Send excel report to non existen patents in rvm"
  task report_non_existent_rvm_patents: :environment do
    not_logging!
    Iclient::Mailer.non_existent_rvm_patents.deliver_later
  end

  desc "Send excel duplicated patents "
  task duplicated_patents: :environment do
    not_logging!
    Iclient::Mailer.duplicated_patents.deliver_later
  end

  desc "Slack alerts for inspections failed"
  task slack_failed_inspections: :environment do
    not_logging!
    Iclient::Reports::SlackInspectionAlerts.new.notify_slack
  end

  desc "Dummy task"
  task dummy: :environment  do
    puts "Rake iclient task"
  end
end

def not_logging!
  dev_null = Logger.new("/dev/null")
  Rails.logger = dev_null
  ActiveRecord::Base.logger = dev_null
end


=begin
ExternalIntegrators::Injector.new(mission: Mission.find('5fa2e772fffbe966ab3f2e5d')).inject

export COMPARA_ID_INGRESO_USUARIO=AUX20190000000801
export COMPARA_RUT_USUARIO=77078150
export COMPARA_ID_USUARIO=32
export COMPARA_ID_INSPECTOR=167
=end