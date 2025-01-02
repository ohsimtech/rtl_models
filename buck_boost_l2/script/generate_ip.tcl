## Script name:   generate_ip
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date: Dec24
## Description: Script to generate IP from Verilog files

set projectDir ../project
set projectName ohs_model_buck_boost
set srdDir ../v
set ipName ohs_model_buck_boost
set ipDir ../../../ip_repo/2024.1/ohs_model_buck_boost
set vendor OpenHardwareSimulator
set library models
set description "Buck-Boost level1 model"

## Add board repository path
# set_param board.repoPaths {/media/pablo/ext_ssd0/board_repository}

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Adding verilog files
add_file [glob $srdDir/model_buck_boost_l1.v]

## package IP project
update_compile_order -fileset sources_1
ipx::package_project -root_dir $ipDir -vendor $vendor -library $library -taxonomy /$vendor/$library -import_files

set_property name $ipName [ipx::current_core]
set_property display_name $ipName [ipx::current_core]
set_property description {$description} [ipx::current_core]
set_property vendor_display_name {$vendor } [ipx::current_core]
set_property company_url http://doc.ohsim.tech [ipx::current_core]

file copy -force ./logo_ip.png $ipDir
ipx::add_file_group -type utility {} [ipx::current_core]
ipx::add_file ./logo_ip.png [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]
set_property type LOGO [ipx::get_files logo_ip.png -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]

# MODEL_DATA_WIDTH configuration
set_property tooltip {The model is generated using fixed point format. This parameter sets width of the input, output and internal signals.} [ipgui::get_guiparamspec -name "MODEL_DATA_WIDTH" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "MODEL_DATA_WIDTH" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters MODEL_DATA_WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 8 [ipx::get_user_parameters MODEL_DATA_WIDTH -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 30 [ipx::get_user_parameters MODEL_DATA_WIDTH -of_objects [ipx::current_core]]

# MODEL_DATA_WIDTH_DECIMAL configuration
set_property tooltip {The model is generated using fixed point format. This parameter sets the position of the comma.} [ipgui::get_guiparamspec -name "MODEL_DATA_WIDTH_DECIMAL" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "MODEL_DATA_WIDTH_DECIMAL" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters MODEL_DATA_WIDTH_DECIMAL -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 8 [ipx::get_user_parameters MODEL_DATA_WIDTH_DECIMAL -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 30 [ipx::get_user_parameters MODEL_DATA_WIDTH_DECIMAL -of_objects [ipx::current_core]]

set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]

ipx::save_core [ipx::current_core]

## Open vivado for verify
# start_gui
exit
