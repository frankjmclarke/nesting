import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';

class UrlListUI extends StatelessWidget {
  final UrlController urlController = Get.put(UrlController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Obx(
            () {
          if (urlController.firestoreUrlList.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<UrlModel> urls = urlController.firestoreUrlList.value!.urls;
            if (urls.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              return ListView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) {
                  final urlModel = urls[index];
                  return Dismissible(
                    key: Key(urlModel.uid),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Item'),
                            content: Text('Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      urlController.deleteUrl(urlModel);
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          urlModel.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          urlModel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editUrlModel(context, urlModel);
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  void _editUrlModel(BuildContext context, UrlModel urlModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUrlScreen(urlModel: urlModel, urlController: urlController,),
      ),
    );
  }
}

class EditUrlScreen extends StatefulWidget {
  final UrlModel urlModel;
  final UrlController urlController;

  EditUrlScreen({required this.urlModel, required this.urlController});

  @override
  _EditUrlScreenState createState() => _EditUrlScreenState();
}


class _EditUrlScreenState extends State<EditUrlScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.urlModel.name;
    _urlController.text = widget.urlModel.url;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Url'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name:'),
            TextFormField(
              controller: _nameController,
            ),
            SizedBox(height: 16.0),
            Text('URL:'),
            TextFormField(
              controller: _urlController,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveChanges(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    String name = _nameController.text.trim();
    String url = _urlController.text.trim();

    // Perform validation
    if (name.isEmpty || url.isEmpty) {
      // Display an error message or show a snackbar indicating missing fields
      return;
    }

    // Create a new UrlModel with the updated values
    UrlModel updatedUrlModel = UrlModel(
      uid: widget.urlModel.uid,
      email: widget.urlModel.email,
      name: name,
      url: url,
    );

    // Call the updateUrl method in the UrlController to save the changes
    widget.urlController.updateUrl(updatedUrlModel);

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

}
