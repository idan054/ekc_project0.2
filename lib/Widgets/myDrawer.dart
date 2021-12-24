import 'package:flutter/material.dart';

Widget myDrawer(context, {onPressed_newProject, onPressed_allUsers,  projectNum}) {
  return Drawer(
      child: Column(
    children: [
      Container(
        padding: const EdgeInsets.only(top: 8.0),
        height: MediaQuery.of(context).size.height * 0.13,
        child: const DrawerHeader(child: Text("Projects")),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: projectNum.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text('Project ${projectNum[i]}'),
              /*                leading: CachedNetworkImage(
                        imageUrl: "http://aarongorka.com/eks-orig.jpg",
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          // print(error);
                          return Icon(Icons.error);
                        },
                      )*/
              // >> << \\
              /*             Image(
                            width: 50,
                              image: AssetImage('Assets/eks-thumb.jpg'))
                              */
            );
          },
        ),
      ),
      TextButton(onPressed: onPressed_newProject, child: const Text('Create New Project')),
      TextButton(onPressed: onPressed_allUsers, child: const Text('Check other users'))
    ],
  ));
}
