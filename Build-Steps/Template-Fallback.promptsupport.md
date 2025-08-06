# Recovery Instructions for $STEP_NAME_PLACEHOLDER

## Context
This step was working on: $STEP_DESCRIPTION_PLACEHOLDER

## What Happened
- **Last Known State**: $LAST_STATE_PLACEHOLDER
- **When It Failed/Paused**: $TIMESTAMP_PLACEHOLDER  
- **Error/Reason**: $ERROR_REASON_PLACEHOLDER

## Files Involved
- **Input Files**: $INPUT_FILES_PLACEHOLDER
- **Output Files**: $OUTPUT_FILES_PLACEHOLDER
- **Modified Files**: $MODIFIED_FILES_PLACEHOLDER
- **Backup Files**: $BACKUP_FILES_PLACEHOLDER

## Recovery Steps

### Option 1: Resume Where Left Off
1. **Check State**: Verify current state of files and environment
2. **Restore Context**: Load any necessary modules or variables
3. **Resume Action**: $RESUME_ACTION_PLACEHOLDER

### Option 2: Restart Step Clean
1. **Cleanup**: Remove partial outputs and temporary files
2. **Reset State**: Restore from backups if needed
3. **Restart**: Begin step from beginning with fresh state

### Option 3: Skip Step (If Safe)
⚠️ **Warning**: Only skip if this step is non-critical to overall build
1. **Mark Skipped**: Update status in Manifest-Build-Progress.md.temp
2. **Document Reason**: Note why step was skipped
3. **Continue**: Proceed to next step

## Verification
After recovery, verify success by:
- $VERIFICATION_1_PLACEHOLDER
- $VERIFICATION_2_PLACEHOLDER
- $VERIFICATION_3_PLACEHOLDER

## Contact Information
- **Original Author**: $AUTHOR_PLACEHOLDER
- **Last Modified By**: $LAST_MODIFIER_PLACEHOLDER
- **Documentation**: See related .md files in docs/ folder

## Debug Information
```powershell
# PowerShell commands to inspect current state
$DEBUG_COMMANDS_PLACEHOLDER
```

## Related Steps
- **Prerequisites**: $PREREQ_STEPS_PLACEHOLDER
- **Dependent Steps**: $DEPENDENT_STEPS_PLACEHOLDER
- **Alternative Steps**: $ALTERNATIVE_STEPS_PLACEHOLDER
