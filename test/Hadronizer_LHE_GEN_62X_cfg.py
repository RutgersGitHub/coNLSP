# Auto generated configuration file
# using: 
# Revision: 1.20 
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v 
# with command line options: None --filein=file:MYFILE.lhe --fileout=file:MYFILE_GEN.root --mc --eventcontent=LHE --datatier=GEN --conditions=START62_V1::All --step=NONE --python_filename=Hadronizer_LHE_GEN_62X_cfg.py --no_exec
import FWCore.ParameterSet.Config as cms
import FWCore.ParameterSet.VarParsing as VarParsing

process = cms.Process('LHE')
options = VarParsing.VarParsing ('analysis')

# import of standard configurations
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

# Modifying default CMSSW settings to the following
options.inputFiles = "file:store/lhe/coNLSP_chargino1400_gluino1700.lhe"
options.outputFile = "store/aodsim/coNLSP_chargino1400_gluino1700.root"

options.section = 1
options.maxEvents = 100

options.tag = "1_GEN"

# Get and parse the command line arguments
options.parseArguments()

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(options.maxEvents)
)

# Input source
process.source = cms.Source("LHESource",
    fileNames = cms.untracked.vstring(
        options.inputFiles
    ),
    firstRun   = cms.untracked.uint32(int(1)),
    firstEvent = cms.untracked.uint32(options.section),
    skipEvents = cms.untracked.uint32(options.section-1)
)

process.options = cms.untracked.PSet(

)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    version = cms.untracked.string('$Revision: 1.20 $'),
    annotation = cms.untracked.string('None nevts:1'),
    name = cms.untracked.string('Applications')
)

# Output definition
process.LHEoutput = cms.OutputModule("PoolOutputModule",
    splitLevel = cms.untracked.int32(0),
    eventAutoFlushCompressedSize = cms.untracked.int32(5242880),
    outputCommands = process.LHEEventContent.outputCommands,
    fileName = cms.untracked.string(
        options.outputFile
    ),
    dataset = cms.untracked.PSet(
        filterName = cms.untracked.string(''),
        dataTier = cms.untracked.string('GEN')
    )
)

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'START62_V1::All', '')

# Path and EndPath definitions
process.LHEoutput_step = cms.EndPath(process.LHEoutput)

# Schedule definition
process.schedule = cms.Schedule(process.LHEoutput_step)

