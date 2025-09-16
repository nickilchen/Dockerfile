/**
 * GDAL JDK8 GDAL2.4.0 Java测试类
 * 用于验证GDAL Java绑定是否正常工作
 */
import org.gdal.gdal.gdal;
import org.gdal.gdal.Dataset;
import org.gdal.gdal.Driver;
import org.gdal.gdalconst.gdalconst;

public class GdalJdk8Gdal240Test {
    
    static {
        // 初始化GDAL
        gdal.AllRegister();
    }
    
    public static void main(String[] args) {
        System.out.println("=== GDAL JDK8 GDAL2.4.0 Java绑定测试 ===");
        
        try {
            // 1. 显示GDAL版本信息
            System.out.println("GDAL版本: " + gdal.VersionInfo("RELEASE_NAME"));
            System.out.println("GDAL版本号: " + gdal.VersionInfo("VERSION_NUM"));
            
            // 2. 显示支持的驱动数量
            int driverCount = gdal.GetDriverCount();
            System.out.println("支持的驱动数量: " + driverCount);
            
            // 3. 检查关键驱动是否可用
            System.out.println("\n=== 关键驱动检查 ===");
            String[] importantDrivers = {"GTiff", "PNG", "JPEG", "HDF5", "HDF4", "netCDF"};
            for (String driverName : importantDrivers) {
                Driver driver = gdal.GetDriverByName(driverName);
                if (driver != null) {
                    System.out.println("✓ " + driverName + " 驱动可用");
                } else {
                    System.out.println("✗ " + driverName + " 驱动不可用");
                }
            }
            
            // 4. 列出前15个支持的格式
            System.out.println("\n支持的格式（前15个）:");
            for (int i = 0; i < Math.min(15, driverCount); i++) {
                var driver = gdal.GetDriver(i);
                if (driver != null) {
                    System.out.println("  " + (i + 1) + ". " + driver.getShortName() + 
                                     " - " + driver.getLongName());
                }
            }
            
            // 5. 测试内存数据集创建
            System.out.println("\n=== 测试内存数据集创建 ===");
            var memDriver = gdal.GetDriverByName("MEM");
            if (memDriver != null) {
                Dataset memDataset = memDriver.Create("", 100, 100, 1, gdalconst.GDT_Byte);
                if (memDataset != null) {
                    System.out.println("✓ 内存数据集创建成功");
                    System.out.println("  宽度: " + memDataset.getRasterXSize());
                    System.out.println("  高度: " + memDataset.getRasterYSize());
                    System.out.println("  波段数: " + memDataset.getRasterCount());
                    memDataset.delete();
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
            
            // 7. 显示GDAL库路径
            System.out.println("\n=== GDAL配置信息 ===");
            System.out.println("GDAL数据路径: " + gdal.GetConfigOption("GDAL_DATA", "未设置"));
            System.out.println("GDAL驱动路径: " + gdal.GetConfigOption("GDAL_DRIVER_PATH", "未设置"));
            
            System.out.println("\n✅ GDAL JDK8 GDAL2.4.0 Java绑定测试完成！");
            
        } catch (Exception e) {
            System.err.println("❌ 测试过程中出现错误: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}