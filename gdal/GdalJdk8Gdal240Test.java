/**
 * GDAL JDK8 GDAL2.4.0 Java测试类
 * 用于验证GDAL Java绑定是否正常工作
 */
public class GdalJdk8Gdal240Test {
    
    public static void main(String[] args) {
        System.out.println("=== GDAL JDK8 GDAL2.4.0 Java绑定测试 ===");
        
        // 首先检查是否可以加载GDAL类
        try {
            Class.forName("org.gdal.gdal.gdal");
            System.out.println("✓ GDAL Java类可以加载");
        } catch (ClassNotFoundException e) {
            System.out.println("✗ GDAL Java类无法加载: " + e.getMessage());
            System.out.println("这可能是因为GDAL Java绑定未正确安装");
            System.exit(1);
        }
        
        try {
            // 动态加载GDAL类以避免编译时依赖
            Class<?> gdalClass = Class.forName("org.gdal.gdal.gdal");
            Class<?> datasetClass = Class.forName("org.gdal.gdal.Dataset");
            Class<?> driverClass = Class.forName("org.gdal.gdal.Driver");
            Class<?> gdalconstClass = Class.forName("org.gdal.gdalconst.gdalconst");
            
            // 调用初始化方法
            java.lang.reflect.Method allRegisterMethod = gdalClass.getMethod("AllRegister");
            allRegisterMethod.invoke(null);
            
            // 1. 显示GDAL版本信息
            java.lang.reflect.Method versionInfoMethod = gdalClass.getMethod("VersionInfo", String.class);
            String versionName = (String) versionInfoMethod.invoke(null, "RELEASE_NAME");
            String versionNum = (String) versionInfoMethod.invoke(null, "VERSION_NUM");
            System.out.println("GDAL版本: " + versionName);
            System.out.println("GDAL版本号: " + versionNum);
            
            // 2. 显示支持的驱动数量
            java.lang.reflect.Method getDriverCountMethod = gdalClass.getMethod("GetDriverCount");
            int driverCount = (Integer) getDriverCountMethod.invoke(null);
            System.out.println("支持的驱动数量: " + driverCount);
            
            // 3. 检查关键驱动是否可用
            System.out.println("\n=== 关键驱动检查 ===");
            java.lang.reflect.Method getDriverByNameMethod = gdalClass.getMethod("GetDriverByName", String.class);
            String[] importantDrivers = {"GTiff", "PNG", "JPEG", "HDF5", "HDF4", "netCDF"};
            for (String driverName : importantDrivers) {
                Object driver = getDriverByNameMethod.invoke(null, driverName);
                if (driver != null) {
                    System.out.println("✓ " + driverName + " 驱动可用");
                } else {
                    System.out.println("✗ " + driverName + " 驱动不可用");
                }
            }
            
            // 4. 列出前15个支持的格式
            System.out.println("\n支持的格式（前15个）:");
            java.lang.reflect.Method getDriverMethod = gdalClass.getMethod("GetDriver", int.class);
            java.lang.reflect.Method getShortNameMethod = driverClass.getMethod("getShortName");
            java.lang.reflect.Method getLongNameMethod = driverClass.getMethod("getLongName");
            for (int i = 0; i < Math.min(15, driverCount); i++) {
                Object driver = getDriverMethod.invoke(null, i);
                if (driver != null) {
                    String shortName = (String) getShortNameMethod.invoke(driver);
                    String longName = (String) getLongNameMethod.invoke(driver);
                    System.out.println("  " + (i + 1) + ". " + shortName + " - " + longName);
                }
            }
            
            // 5. 测试内存数据集创建
            System.out.println("\n=== 测试内存数据集创建 ===");
            Object memDriver = getDriverByNameMethod.invoke(null, "MEM");
            if (memDriver != null) {
                java.lang.reflect.Method createMethod = driverClass.getMethod("Create", String.class, int.class, int.class, int.class, int.class);
                // 获取GDT_Byte常量值
                java.lang.reflect.Field gdtByteField = gdalconstClass.getField("GDT_Byte");
                int gdtByteValue = gdtByteField.getInt(null);
                Object memDataset = createMethod.invoke(memDriver, "", 100, 100, 1, gdtByteValue);
                if (memDataset != null) {
                    System.out.println("✓ 内存数据集创建成功");
                    java.lang.reflect.Method getRasterXSizeMethod = datasetClass.getMethod("getRasterXSize");
                    java.lang.reflect.Method getRasterYSizeMethod = datasetClass.getMethod("getRasterYSize");
                    java.lang.reflect.Method getRasterCountMethod = datasetClass.getMethod("getRasterCount");
                    System.out.println("  宽度: " + getRasterXSizeMethod.invoke(memDataset));
                    System.out.println("  高度: " + getRasterYSizeMethod.invoke(memDataset));
                    System.out.println("  波段数: " + getRasterCountMethod.invoke(memDataset));
                    // 清理资源
                    java.lang.reflect.Method deleteMethod = datasetClass.getMethod("delete");
                    deleteMethod.invoke(memDataset);
                } else {
                    System.out.println("✗ 内存数据集创建失败");
                }
            } else {
                System.out.println("✗ MEM驱动不可用");
            }
            
            // 6. 显示Java环境信息
            System.out.println("\n=== Java环境信息 ===");
            System.out.println("Java版本: " + System.getProperty("java.version"));
            System.out.println("Java供应商: " + System.getProperty("java.vendor"));
            System.out.println("操作系统: " + System.getProperty("os.name") + " " + 
                             System.getProperty("os.arch"));
            System.out.println("JAVA_HOME: " + System.getenv("JAVA_HOME"));
            System.out.println("CLASSPATH: " + System.getProperty("java.class.path"));
            
            // 7. 显示GDAL配置信息
            System.out.println("\n=== GDAL配置信息 ===");
            java.lang.reflect.Method getConfigOptionMethod = gdalClass.getMethod("GetConfigOption", String.class, String.class);
            String gdalData = (String) getConfigOptionMethod.invoke(null, "GDAL_DATA", "未设置");
            String gdalDriverPath = (String) getConfigOptionMethod.invoke(null, "GDAL_DRIVER_PATH", "未设置");
            System.out.println("GDAL数据路径: " + gdalData);
            System.out.println("GDAL驱动路径: " + gdalDriverPath);
            
            System.out.println("\n✅ GDAL JDK8 GDAL2.4.0 Java绑定测试完成！");
            
        } catch (Exception e) {
            System.err.println("❌ 测试过程中出现错误: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}