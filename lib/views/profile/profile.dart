// ignore_for_file: file_names, unused_import, library_private_types_in_public_api
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taskwarrior/model/storage/savefile.dart';
import 'package:taskwarrior/taskserver/configure_taskserver.dart';
import 'package:taskwarrior/widgets/pallete.dart';
import 'package:taskwarrior/widgets/profilefunctions.dart';
import 'package:taskwarrior/widgets/taskdetails.dart';
import 'package:taskwarrior/routes/pageroute.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);

    var profilesMap = ProfilesWidget.of(context).profilesMap;
    var currentProfile = ProfilesWidget.of(context).currentProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.kToDark,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, PageRoutes.home);
          },
          icon: const Icon(Icons.home_outlined, color: Colors.white),
        ),
      ),
      //primary: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfilesColumn(
              profilesMap,
              currentProfile,
              profilesWidget.addProfile,
              profilesWidget.selectProfile,
              () => showDialog(
                context: context,
                builder: (context) => RenameProfileDialog(
                  profile: currentProfile,
                  alias: profilesMap[currentProfile],
                  context: context,
                ),
              ),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConfigureTaskserverRoute(),
                ),
              ),
              () {
                var tasks =
                    profilesWidget.getStorage(currentProfile).data.export();
                var now = DateTime.now()
                    .toIso8601String()
                    .replaceAll(RegExp(r'[-:]'), '')
                    .replaceAll(RegExp(r'\..*'), '');
                exportTasks(
                  contents: tasks,
                  suggestedName: 'tasks-$now.txt',
                );
              },
              () => profilesWidget.copyConfigToNewProfile(currentProfile),
              () => showDialog(
                context: context,
                builder: (context) => DeleteProfileDialog(
                  profile: currentProfile,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilesColumn extends StatelessWidget {
  const ProfilesColumn(
    this.profilesMap,
    this.currentProfile,
    this.addProfile,
    this.selectProfile,
    this.rename,
    this.configure,
    this.export,
    this.copy,
    this.delete, {
    Key? key,
  }) : super(key: key);

  final Map profilesMap;
  final String currentProfile;
  final void Function() addProfile;
  final void Function(String) selectProfile;
  final void Function() rename;
  final void Function() configure;
  final void Function() export;
  final void Function() copy;
  final void Function() delete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Profiles'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: addProfile,
          ),
        ),
        SelectProfile(currentProfile, profilesMap, selectProfile),
        ManageProfile(rename, configure, export, copy, delete),
      ],
    );
  }
}
