import 'package:flutter/material.dart';
import 'package:project/AdminScreen/AddCatgeory.dart';
import 'package:project/AdminScreen/AddSeller.dart';
import 'package:project/AdminScreen/AddWorkers.dart';
import 'package:project/AdminScreen/AdminChat.dart';
import 'package:project/AdminScreen/AdminIndex.dart';
import 'package:project/AdminScreen/Competition.dart';
import 'package:project/AdminScreen/Register.dart';
import 'package:project/AdminScreen/ShowSeller.dart';
import 'package:project/AdminScreen/ShowWorkers.dart';
import 'package:project/Components/AccountAdminLogin.dart';
import 'package:project/Components/AccountPostScreens/AccountIndex.dart';
import 'package:project/Components/Login.dart';
import 'package:project/Components/MasterLogin.dart';
import 'package:project/Components/NgoLogin.dart';
import 'package:project/Components/NgoScreen/NgoIndex.dart';
import 'package:project/Components/SellerLogin.dart';
import 'package:project/Components/Signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/Components/WorkerLogin.dart';
import 'package:project/SellerScreen.dart/SellerIndex.dart';
import 'package:project/SellerScreen.dart/SellerMessage.dart';
import 'package:project/SellerScreen.dart/SellerProduct.dart';
import 'package:project/TradersScreen/TradersIndex.dart';
import 'package:project/UserScreen/AddCompetition.dart';
import 'package:project/UserScreen/Camera.dart';
import 'package:project/UserScreen/CreatePost.dart';
import 'package:project/UserScreen/EcoStore.dart';
import 'package:project/UserScreen/EditProfile.dart';
import 'package:project/UserScreen/Joinus.dart';
import 'package:project/UserScreen/MainHome.dart';
import 'package:project/UserScreen/PushNotification.dart';
import 'package:project/UserScreen/RealTimeApi.dart';
import 'package:project/UserScreen/SellWaste.dart';
import 'package:project/UserScreen/Social.dart';
import 'package:project/UserScreen/SocialScroll.dart';
import 'package:project/UserScreen/cart.dart';
import 'package:project/UserScreen/chat.dart';
import 'package:project/WorkerScreen/WorkerIndex.dart';
import 'package:project/WorkerScreen/WorkerMessage.dart';
import 'package:project/firebase_options.dart';

void main() async {
    await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized(); // ✅ important for path_provider & camera
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      title: 'EcoCycle.pk',
    
      home: const MasterHome(),
            routes: {
        '/mainhome' : (context) => const MasterHome(),
        '/Login': (context) => const Login(),
        '/Signup': (context) => const Signup(),
        '/admin': (context) => const AdminIndex(),
        '/EditProfile': (context) => const EditProfile(),
        '/workers': (context) => const AddWorkers(),
        '/registerall': (context) => const Register(),
        '/addseller': (context) => const AddSeller(),
        '/EcoStore': (context) => const EcoStore(),
        '/createpost': (context) => const CreatePostScreen(),
        '/createpost': (context) => const CreatePostScreen(),
        '/SellWaste': (context) => const SellWaste(),
        '/cart': (context) => const Cart(),
        '/RealTimeApi': (context) => const EcoMonitorPage(),
        '/Joinus': (context) => const Joinus(),
        '/WorkerIndex': (context) => const  WorkerIndex(),
        '/ShowWorkers': (context) => const  ShowWorkers(),
        '/ShowSeller': (context) => const  ShowSeller(),
        '/comp': (context) => const  Competition(),
        '/AddCompetition': (context) => const  AddCompetition(),
        '/PushNotification': (context) => const  PushNotification(),
        '/AdminChat': (context) => const  AdminChat(),
        '/WorkerMessage': (context) => const  WorkerMessage(),
        '/SellerIndex': (context) => const  SellerIndex(),
        '/SellerMessage': (context) => const  SellerMessage(),
        '/Social': (context) => const  SocialScroll(),
        '/PanelSocial': (context) => const  Social(),
        '/WorkerLogin': (context) => const  WorkerLogin(),
        '/SellerLogin': (context) => const  SellerLogin(),
        '/NgoIndex': (context) => const  NgoIndex(),
        '/NgoLogin': (context) => const  NgoLogin(),
        '/SellerProduct': (context) => const  SellerProduct(),
        '/AdminAcountIndex': (context) => const  AccountIndex(),
        '/AdminAcountLogin': (context) => const  AccountAdminLogin(),
        '/MasterLogin': (context) => const  MasterLogin(),
        '/TradersIndex': (context) => const  TradersIndex(),
        '/AddCatgeory': (context) => const  AddCatgeory(),


        ChatPage.routeName: (context) => const ChatPage(),



      },
    );
  }
}
