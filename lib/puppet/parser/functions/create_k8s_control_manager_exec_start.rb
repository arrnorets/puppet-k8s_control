#
# Returns ExecStart string for k8s control manager service in k8s cluster
#

module Puppet::Parser::Functions
  newfunction(:create_k8s_control_manager_exec_start, :type => :rvalue, :doc => <<-EOS
    Returns ExecStart string for k8s control manager
    EOS
  ) do |arguments|
    k8s_control_manager_binarypath = arguments[0]
    k8s_control_manager_config_hash = arguments[1]

    exec_start_string = "ExecStart=" + k8s_control_manager_binarypath + " \\" + "\n"
    k8s_control_manager_config_hash["common"].each do |k, v|
      exec_start_string = exec_start_string + " --" + k + "=" + v.to_s + " \\" + "\n" 
    end
    
    return exec_start_string[0...-2] + "\n"
  
  end
end

# vim: set ts=2 sw=2 et :
