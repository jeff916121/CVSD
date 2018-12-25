setVerifyGeometryMode -area { 0 0 0 0 }
saveDesign CHIP/powerroute
createBasicPathGroups -expanded
get_path_groups 
place_opt_design
checkPlace CHIP.checkPlace
