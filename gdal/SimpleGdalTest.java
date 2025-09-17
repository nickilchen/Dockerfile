/**
 * 简单的GDAL测试程序
 * 用于验证GDAL是否正确安装
 */
public class SimpleGdalTest {
    public static void main(String[] args) {
        System.out.println("=== 简单GDAL测试 ===");
        
        try {
            // 尝试加载GDAL类
            Class<?> gdalClass = Class.forName("org.gdal.gdal.gdal");
            System.out.println("✓ GDAL类加载成功");
            
            // 尝试调用VersionInfo方法
            java.lang.reflect.Method versionInfoMethod = gdalClass.getMethod("VersionInfo", String.class);
            String version = (String) versionInfoMethod.invoke(null, "RELEASE_NAME");
            System.out.println("GDAL版本: " + version);
            
            System.out.println("✅ 简单GDAL测试通过！");
        } catch (ClassNotFoundException e) {
            System.out.println("✗ GDAL类未找到: " + e.getMessage());
            System.out.println("这可能是因为GDAL Java绑定未正确安装");
        } catch (Exception e) {
            System.out.println("❌ 测试过程中出现错误: " + e.getMessage());
            e.printStackTrace();
        }
    }
}