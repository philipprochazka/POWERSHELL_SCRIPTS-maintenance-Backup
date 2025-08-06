# XML Schema Foundation - Recovery Instructions

## Step Overview
This step creates the foundational XML schemas for the v4 Alpha architecture.

## If This Step Fails

### Common Issues and Solutions

#### Issue: Schema Validation Errors
**Symptoms**: XSD files fail validation or don't parse correctly
**Solution**:
1. Check XML syntax with online validator
2. Ensure all required elements are defined
3. Verify namespace declarations are correct
4. Test with minimal sample XML files first

#### Issue: Performance Concerns
**Symptoms**: Schema parsing is too slow for runtime use
**Solution**:
1. Simplify complex validation rules
2. Use XSD restrictions instead of complex patterns
3. Consider schema compilation for faster parsing
4. Implement schema caching mechanisms

#### Issue: Extensibility Problems
**Symptoms**: Cannot add custom elements or attributes
**Solution**:
1. Add xs:any elements for extensibility
2. Use abstract types for inheritance
3. Implement proper namespace handling
4. Design for forward compatibility

### Recovery Steps

1. **Check Existing Progress**
   ```powershell
   Get-ChildItem "C:\backup\Powershell\Build-Steps\XML-Schema-Foundation [IN_PROGRESS]" -Filter "*.xsd"
   ```

2. **Validate Existing Schemas**
   ```powershell
   # Test schema validity
   $schema = [xml](Get-Content "ProfileManifest.xsd")
   ```

3. **Resume from Last Working State**
   - If ProfileManifest.xsd exists and is valid: Continue with ModuleDefinition.xsd
   - If ModuleDefinition.xsd exists: Continue with FunctionRegistry.xsd
   - If all schemas exist: Move to Runtime-Parser-Engine step

4. **Start Fresh if Needed**
   - Delete corrupted schema files
   - Use templates from Template-Schema-Foundation.xsd
   - Follow implementation guide step by step

### Testing the Step
```powershell
# Validate schema files
$schemas = @("ProfileManifest.xsd", "ModuleDefinition.xsd", "FunctionRegistry.xsd")
foreach ($schema in $schemas) {
    if (Test-Path $schema) {
        try {
            [xml]$schemaContent = Get-Content $schema
            Write-Host "✅ $schema is valid" -ForegroundColor Green
        } catch {
            Write-Host "❌ $schema has errors: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
```

### Success Criteria
- [ ] All three XSD schema files created and valid
- [ ] Sample XML files validate against schemas
- [ ] Schemas support extensibility requirements
- [ ] Performance testing shows acceptable parsing times

### Next Step Preparation
Once this step completes successfully:
1. Update step status to COMPLETED
2. Create Runtime-Parser-Engine step folder
3. Begin PowerShell XML parsing implementation
