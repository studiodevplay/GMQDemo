using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;

#if UNITY_IOS
using UnityEditor.iOS.Xcode;

public class XCodeBuildPostProcessor
{
    [PostProcessBuildAttribute(1)]
    public static void OnPostProcessBuild(BuildTarget target, string path)
    {
        if (target != BuildTarget.iOS)
        {
            Debug.Log("Target is not iOS. XCodePostProcess will not run.");
            return;
        }
        ///应用名字本地化 
        if(true){
            //1.根据build_path获取proj_path
            string projpath = ChillyRoom.UnityEditor.iOS.Xcode.PBXProject.GetPBXProjectPath(path);
            //创建proj对象
            ChillyRoom.UnityEditor.iOS.Xcode.PBXProject proj = new ChillyRoom.UnityEditor.iOS.Xcode.PBXProject();
            //加载proj
            proj.ReadFromString(File.ReadAllText(projpath));
            //生成本地化文件配置
            AddLocalization(proj);
            //保存
            proj.WriteToFile(projpath);
        }
       
        // Read.

        string projectPath = PBXProject.GetPBXProjectPath(path);

        PBXProject project = new PBXProject();
        project.ReadFromString(File.ReadAllText(projectPath));


        string targetFrameworkGUID = project.GetUnityFrameworkTargetGuid();
        string targetMainGUID = project.GetUnityMainTargetGuid();

        AppleEnableAutomaticSigning();

        //capability设置
        //var capManager = new ProjectCapabilityManager(projectPath, "z.entitlements");
        // SetCapabilities(capManager);

        AddShellScriptBuildPhase(project,targetMainGUID);

        ProjectSetting(project);

        
        // Write.
        File.WriteAllText(projectPath, project.WriteToString());
    }


    private static void ECKAddResourceGroupToiOSProject(string xcodePath, PBXProject proj, string target, string resourceDirectoryPath, string fileName)
    {



    }
    static void AddBuildProperties(UnityEditor.iOS.Xcode.PBXProject project, string targetGUID)
    {
      
        project.SetBuildProperty(targetGUID, "ENABLE_BITCODE", "false");
        project.AddBuildProperty(targetGUID, "OTHER_LDFLAGS", "-ObjC");

        // TopOn
        project.SetBuildProperty(targetGUID, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");
        project.SetBuildProperty(targetGUID, "GCC_C_LANGUAGE_STANDARD", "gnu99");
        project.AddBuildProperty(targetGUID, "OTHER_LDFLAGS", "-fobjc-arc");
    }
    /// <summary>
    /// 添加Frameworks
    /// </summary>
    /// <param name="project"></param>
    /// <param name="targetGUID"></param>
    static void AddFrameworks(UnityEditor.iOS.Xcode.PBXProject project, string targetGUID)
    {
        project.AddFrameworkToProject(targetGUID, "libz.dylib", false);
        project.AddFrameworkToProject(targetGUID, "libbz2.tbd", false);
        project.AddFrameworkToProject(targetGUID, "libc++.dylib", false);
        project.AddFrameworkToProject(targetGUID, "libresolv.9.dylib", false);
        project.AddFrameworkToProject(targetGUID, "libsqlite3.tbd", false);

        project.AddFrameworkToProject(targetGUID, "MediaPlayer.framework", false);
        project.AddFrameworkToProject(targetGUID, "Accelerate.framework", false);
        project.AddFrameworkToProject(targetGUID, "AVFoundation.framework", false);
        project.AddFrameworkToProject(targetGUID, "UserNotifications.framework", false);
        project.AddFrameworkToProject(targetGUID, "SystemConfiguration.framework", false);
        project.AddFrameworkToProject(targetGUID, "QuartzCore.framework", false);
    }


    /// <summary>
    ///Run Script脚本去掉不支持框架
    /// </summary>
    /// <param name="project"></param>
    /// <param name="targetGUID"></param>
    static void AddShellScriptBuildPhase(UnityEditor.iOS.Xcode.PBXProject project, string targetGUID)
    {

        string str1 = "\"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Frameworks/UnityFramework.framework/\"\n";
        string str2 = " \"Frameworks\" ";
        string RunScript = "cd " + str1 + "if [[ -d" + str2 + "]]" + ';' + " then rm -fr Frameworks \n fi";
        project.AddShellScriptBuildPhase(targetGUID, "Run Script", "/bin/sh", RunScript);
    }


    /// <summary>
    /// project的设置
    /// </summary>
    /// <param name="project"></param>
    static void ProjectSetting(UnityEditor.iOS.Xcode.PBXProject project)
    {
        string projectGUID = project.ProjectGuid();
        project.SetBuildProperty(projectGUID, "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES", "YES");
    }

    /// <summary>
    /// 设置证书
    /// </summary>
    static void AppleEnableAutomaticSigning()
    {
        //xxxx为你的证书的ID
        PlayerSettings.iOS.appleEnableAutomaticSigning = true;

        PlayerSettings.iOS.appleDeveloperTeamID = "M5755ZY668";

    }

    /// <summary>
    /// 暂时没用过
    /// </summary>
    /// <param name="manager"></param>
    private static void SetCapabilities(ProjectCapabilityManager manager)
    {
        //推送
        manager.AddPushNotifications(true);
        //内购
        manager.AddInAppPurchase();
        manager.WriteToFile();
    }

    /// <summary>
    /// 暂时没用过
    /// </summary>
    /// <param name="project"></param>
    /// <param name="targetGUID"></param>
    static void AddEmbedFrameworks(UnityEditor.iOS.Xcode.PBXProject project, string targetGUID)
    {
        const string defaultLocationInProj = "Plugins/iOS/FacebookSDK/";

        //project.AddFileToEmbedFrameworks(targetGUID, project.AddFile(Path.Combine(defaultLocationInProj, "FBSDKCoreKit.framework"), "Frameworks/Plugins/iOS/FacebookSDK/FBSDKCoreKit.framework", PBXSourceTree.Source));
        //project.AddFileToEmbedFrameworks(targetGUID, project.AddFile(Path.Combine(defaultLocationInProj, "FBSDKLoginKit.framework"), "Frameworks/Plugins/iOS/FacebookSDK/FBSDKLoginKit.framework", PBXSourceTree.Source));
        //project.AddFileToEmbedFrameworks(targetGUID, project.AddFile(Path.Combine(defaultLocationInProj, "FBSDKGamingServicesKit.framework"), "Frameworks/Plugins/iOS/FacebookSDK/FBSDKGamingServicesKit.framework", PBXSourceTree.Source));
        //project.AddFileToEmbedFrameworks(targetGUID, project.AddFile(Path.Combine(defaultLocationInProj, "FBSDKShareKit.framework"), "Frameworks/Plugins/iOS/FacebookSDK/FBSDKShareKit.framework", PBXSourceTree.Source));

        // TopOn
        project.AddFileToBuild(targetGUID, project.AddFile("usr/lib/libxml2.tbd", "Libraries/libxml2.tbd", PBXSourceTree.Sdk));
        project.AddFileToBuild(targetGUID, project.AddFile("usr/lib/libresolv.9.tbd", "Libraries/libresolv.9.tbd", PBXSourceTree.Sdk));

    }

   

    static void CopyDirectory(string sourceDirPath, string SaveDirPath)
    {

    }

    static void EditorPlist(string path)
    {
        string plistPath = path + "/Info.plist";
        PlistDocument plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));
        PlistElementDict rootDict = plist.root;

        ///缺少合规证明
        rootDict.SetBoolean("ITSAppUsesNonExemptEncryption", false);



        //权限
        //rootDict.SetString("NSPhotoLibraryUsageDescription", "we need use photo usage");
        //rootDict.SetString("NSCameraUsageDescription", "we need use camera usage");
        //rootDict.SetString("NSPhotoLibraryAddUsageDescription", "we need add photo to your library");

        //rootDict.SetString("NSCalendarsUsageDescription", "we need use calendars");
        //rootDict.SetString("NSMicrophoneUsageDescription", "we need use microphone");
        //rootDict.SetString("NSLocationWhenInUseUsageDescription", "we need use location when in use");

        //PlistElementDict securityDict = rootDict.CreateDict("NSAppTransportSecurity");
        //securityDict.SetBoolean("NSAllowsArbitraryLoads", true);
        //securityDict.SetBoolean("NSAllowsArbitraryLoadsForMedia", true);
        //securityDict.SetBoolean("NSAllowsArbitraryLoadsInWebContent", true);


        //urlTypes权限
        //PlistElementArray urlTypes = plist.root.CreateArray("CFBundleURLTypes");
        //PlistElementDict itemDict;

        //itemDict = urlTypes.AddDict();
        //itemDict.SetString("CFBundleTypeRole", "Editor");
        //PlistElementArray schemesArray1 = itemDict.CreateArray("CFBundleURLSchemes");
        //schemesArray1.AddString("fb332342027809316");


        ///删除权限
        // remove exit on suspend if it exists.
        string exitsOnSuspendKey = "UIApplicationExitsOnSuspend";
        if (rootDict.values.ContainsKey(exitsOnSuspendKey))
        {
            rootDict.values.Remove(exitsOnSuspendKey);
        }
        plist.WriteToFile(plistPath);





    }
    static void AddLocalization(ChillyRoom.UnityEditor.iOS.Xcode.PBXProject project)
    {


        var infoDirs = Directory.GetDirectories(Application.dataPath + "/IOSFile/lang/infoplist/");
        for (var i = 0; i < infoDirs.Length; ++i)
        {
            var files = Directory.GetFiles(infoDirs[i], "*.strings");
            if (files != null & files.Length > 0)
            {
                string filepath = files[0];
                //个人理解:
                //参数1:文件群组名(本地化文件群组名为"InfoPlist.strings"
                //参数2:本地化文件名(保存于文件群组的文件名(Xcode上表现的名称?);
                //参数3:本地化文件绝对路径（unity工程上的?)
                project.AddLocalization("InfoPlist.strings", "InfoPlists.strings", filepath);
            }
        }

    }

    static void EditorUnityAppController(string path)
    {
    }
}
#endif