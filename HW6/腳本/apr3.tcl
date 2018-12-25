setVerifyGeometryMode -area { 0 0 0 0 }
saveDesign CHIP/powerplan
setSrouteMode -viaConnectToShape { ring }
sroute -connect { corePin } -layerChangeRange { METAL1(1) METAL8(8) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { METAL1(1) METAL8(8) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { METAL1(1) METAL8(8) }
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference pgPower -isVisible 0
setLayerPreference pgGround -isVisible 0
setLayerPreference clock -isVisible 0
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference pgPower -isVisible 1
setLayerPreference pgGround -isVisible 1
setLayerPreference clock -isVisible 1
setLayerPreference net -isVisible 0
setLayerPreference power -isVisible 0
setLayerPreference pgPower -isVisible 0
setLayerPreference pgGround -isVisible 0
setLayerPreference clock -isVisible 0
setLayerPreference net -isVisible 1
setLayerPreference power -isVisible 1
setLayerPreference pgPower -isVisible 1
setLayerPreference pgGround -isVisible 1
setLayerPreference clock -isVisible 1
setLayerPreference net -isSelectable 0
setLayerPreference power -isSelectable 0
setLayerPreference pgPower -isSelectable 0
setLayerPreference pgGround -isSelectable 0
setLayerPreference clock -isSelectable 0
setLayerPreference net -isSelectable 1
setLayerPreference power -isSelectable 1
setLayerPreference pgPower -isSelectable 1
setLayerPreference pgGround -isSelectable 1
setLayerPreference clock -isSelectable 1
addIoFiller -cell PFEED20Z -prefix IOFILLER
addIoFiller -cell PFEED10Z -prefix IOFILLER
addIoFiller -cell PFEED5Z -prefix IOFILLER
addIoFiller -cell PFEED1Z -prefix IOFILLER
addIoFiller -cell PFEED0_1Z -prefix IOFILLER
addIoFiller -cell PFEED0_01Z -prefix IOFILLER
addIoFiller -cell PFEED0_005Z -prefix IOFILLER -fillAnyGap
redraw
panPage -1 0
panPage 0 1
panPage 0 -1
verifyConnectivity -type all -noUnroutedNet -error 1000 -warning 50
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
