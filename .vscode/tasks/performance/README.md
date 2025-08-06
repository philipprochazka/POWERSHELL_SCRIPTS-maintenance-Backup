# ⚡ Performance Testing Tasks

This module contains tasks for performance testing, benchmarking, and optimization of PowerShell profiles.

## 📋 Available Tasks

### Quick Performance Tests

#### ⚡ Test Ultra-Performance Startup Speed
Quick startup speed test for ultra-performance profile.
- Tests 5 iterations of startup
- Measures millisecond timing
- Shows average and fastest times
- Realistic performance thresholds:
  - Excellent: < 200ms
  - Very Good: 200-500ms  
  - Needs optimization: > 500ms

#### 📊 Benchmark Profile Performance
Standard performance benchmarking.
- Runs Test-DraculaPerformance.ps1
- 5 iteration default
- Compares different profile modes
- Basic performance metrics

### Comprehensive Analysis

#### 🎯 Compare All Ultra-Performance Versions
**Default test task** - Comprehensive comparison of all profile versions.
- Tests V3, V4, and original profiles
- Includes Lorem Ipsum stress testing
- Generates detailed HTML report
- Performance trend analysis

#### 🏆 Ultra-Performance Comparison (Quick)
Fast comparison test with basic metrics.
- Quick test mode
- Generates HTML report
- Essential benchmarks only
- Good for regular checks

#### 📊 Ultra-Performance Comparison (Standard)
Standard comparison with 15 iterations.
- More reliable averages
- Detailed timing analysis
- Comprehensive report generation
- Recommended for regular testing

#### 🚀 Ultra-Performance Comparison (Comprehensive)
Most thorough performance analysis.
- Includes Lorem Ipsum stress tests
- Complete feature testing
- Detailed HTML reports
- Memory usage analysis

### Specialized Tests

#### 📝 Lorem Ipsum Stress Test
Large text processing stress test.
- 5000 character Lorem Ipsum text
- Tests text rendering performance
- Memory pressure simulation
- PowerShell parsing stress test

#### 🧪 Test Performance Metrics
Detailed performance metrics collection.
- Module loading profiling
- Memory usage tracking
- Function call timing
- Performance regression detection

#### 🎯 Test Realistic Performance Thresholds (200ms/500ms)
Tests with updated realistic performance expectations.
- Acknowledges Oh My Posh overhead
- Realistic targets for modern systems
- Performance classification:
  - ⚡ Excellent: < 200ms
  - ✅ Very Good: 200-500ms
  - 👍 Good: 500-750ms
  - ⚠️ Needs Optimization: > 750ms

### Optimization Analysis

#### 🔬 Performance Analysis (Quick)
Quick optimization analysis.
- Fast performance scan
- Basic recommendations
- Quick wins identification

#### 📊 Performance Analysis (Standard)
Standard optimization analysis with reports.
- Detailed analysis
- Performance bottleneck identification
- Optimization recommendations
- HTML report generation

#### 🏆 Performance Analysis (Comprehensive)
Most thorough optimization analysis.
- Complete profile comparison
- Detailed bottleneck analysis
- Memory usage optimization
- Advanced reporting

### Debug Tools

#### 🔧 Enable Performance Debug Mode
Enables performance debugging environment variables.
- Sets DRACULA_PERFORMANCE_DEBUG=true
- Sets DRACULA_SHOW_STARTUP=true
- Shows detailed timing information
- Requires PowerShell restart

#### 🔇 Disable Performance Debug Mode
Disables performance debugging.
- Removes debug environment variables
- Returns to normal operation
- Reduces console output

## 🎯 Usage Recommendations

### Regular Testing
1. Run "⚡ Test Ultra-Performance Startup Speed" for quick checks
2. Use "🎯 Compare All Ultra-Performance Versions" weekly
3. Monitor trends with generated HTML reports

### Optimization Workflow
1. Enable debug mode: "🔧 Enable Performance Debug Mode"
2. Run comprehensive analysis: "🏆 Performance Analysis (Comprehensive)"
3. Apply optimizations based on recommendations
4. Validate with "📊 Ultra-Performance Comparison (Standard)"

### Stress Testing
1. Use "📝 Lorem Ipsum Stress Test" for text processing
2. Run "🚀 Ultra-Performance Comparison (Comprehensive)" for full testing
3. Check memory usage and GC pressure

## 📊 Performance Targets

### Realistic Expectations (Updated)
- **V3/V4 Ultra-Performance**: Target < 200ms (Excellent)
- **Original Profile**: Target < 500ms (Very Good)
- **With Oh My Posh**: Add 50-100ms overhead
- **System Considerations**: First run may be slower due to .NET JIT

### Performance Classifications
- **⚡ Excellent**: < 200ms - Optimal performance
- **✅ Very Good**: 200-500ms - Acceptable for daily use
- **👍 Good**: 500-750ms - Minor optimization needed
- **⚠️ Needs Attention**: > 750ms - Performance issues

## 📁 Related Files

- `${workspaceFolder}/Test-UltraPerformanceComparison.ps1` - Main comparison script
- `${workspaceFolder}/Test-DraculaPerformance.ps1` - Performance testing
- `${workspaceFolder}/Start-DraculaOptimizationAnalysis.ps1` - Optimization analysis
- `${workspaceFolder}/Test-DraculaProfileMetrics.ps1` - Metrics collection
- Performance reports generated in workspace root

## 🔧 Requirements

- PowerShell 7+ recommended
- Measure-Command cmdlet availability
- Write/read access for report generation
- Multiple profile variants for comparison testing
