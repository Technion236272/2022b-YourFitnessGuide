import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class FirstTab extends StatelessWidget {
  String uid;
  FirstTab({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostManager _postManager = PostManager();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
        stream: _postManager.getUserPosts(uid),
        builder: (context, snapshot) { return RefreshIndicator( onRefresh: () async{ print('Refreshing'); return null; },
            child:
            ListView.builder(
              //separatorBuilder: (context, index) => const Divider(),
              itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == null) {
                  return const Center(child: Text('No data available'));
                }
                return post(snapshot: snapshot, index: index);
              },
            ));
        }
    );
  }
}

/*
FutureBuilder<QuerySnapshot<Map<String, dynamic>?>>(
        future: _postManager.getAllPosts(),
        builder: (context, snapshot) { return RefreshIndicator( onRefresh: () async{ print('Refreshing'); return null; },
        child:
          ListView.builder(
            //separatorBuilder: (context, index) => const Divider(),
            itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }

              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == null) {
                return const Center(child: Text('No data available'));
              }

              return Card(
                elevation: 5,
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.fromLTRB(16,8,16,8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// user pic + name + 3 dots
                      StreamBuilder<Map<String, dynamic>?>(
                          stream: _postManager
                              .getUserInfo(snapshot.data!.docs[index]
                              .data()!['user_uid'])
                              .asStream(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting
                                && userSnapshot.data == null) {
                              return const Center(child: LinearProgressIndicator());
                            }
                            if (userSnapshot.connectionState == ConnectionState.done
                                && userSnapshot.data == null) {
                              return const ListTile();
                            }
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(userSnapshot.data!['picture']!),
                              ),
                              title: RichText(
                                text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(text: snapshot.data!.docs[index].data()!['category'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).appBarTheme.backgroundColor
                                        )
                                    ),
                                    const TextSpan(text: ' by '),
                                    TextSpan(text: userSnapshot.data!['name']),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                  timeago.format(
                                      snapshot.data!.docs[index]
                                          .data()!['createdAt']
                                          .toDate(),
                                      allowFromNow: true),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey)),
                              trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color:
                                    Theme.of(context).iconTheme.color,
                                  )),
                            );
                          }),
                      Text(snapshot.data!.docs[index].data()!['title']!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(snapshot.data!.docs[index].data()!['description']!,
                          textAlign: TextAlign.left,
                      ),
                      (snapshot.data!.docs[index].data()!['image_url'] != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            snapshot.data!.docs[index].data()!['image_url']!,
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Padding(padding: EdgeInsets.all(0))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: (){
                                    const _snackBar = SnackBar(content: Text('Not implemented yet'));
                                    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                                  },
                                  icon: const Icon(Icons.arrow_upward, color: Colors.grey)
                              ),
                              IconButton(
                                  onPressed: (){
                                    const _snackBar = SnackBar(content: Text('Not implemented yet'));
                                    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                                  },
                                  icon: const Icon(Icons.arrow_downward, color: Colors.grey)
                              )
                            ],
                          ),
                          IconButton(
                              onPressed: (){
                                const _snackBar = SnackBar(content: Text('Not implemented yet'));
                                ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                              },
                              icon: const Icon(Icons.chat_bubble, color: Colors.grey)
                          ),
                          IconButton(
                              onPressed: (){
                                const _snackBar = SnackBar(content: Text('Not implemented yet'));
                                ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                              },
                              icon: const Icon(Icons.bookmark, color: Colors.grey)
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ));
          }
      )



 */