import 'package:badges/badges.dart';
import 'package:desi_karaoke_lite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicTile extends StatefulWidget {
  final Music music;
  final Function onTap;
  final SharedPreferences prefs;

  MusicTile({@required this.music, this.onTap, @required this.prefs});

  @override
  _MusicTileState createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Hero(
          child: ListTile(
            onTap: () => widget.onTap(widget.music),
            leading: CircleAvatar(
              child: Icon(Icons.music_note),
            ),
            title: Text(widget.music.effectivetitle),
            subtitle: Text(widget.music.effectiveartist),
            trailing: widget.music.isFavorite
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.heart_solid,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      widget.music.isFavorite = false;
                      var list = widget.prefs
                              .getStringList(SharedPreferencesKeys.FAVORITES) ??
                          List<String>();
                      list.remove(widget.music.key);
                      widget.prefs
                          .setStringList(SharedPreferencesKeys.FAVORITES, list);
                      setState(() {});
                    },
                  )
                : IconButton(
                    icon: Icon(CupertinoIcons.heart),
                    onPressed: () {
                      widget.music.isFavorite = true;
                      var list = widget.prefs
                              .getStringList(SharedPreferencesKeys.FAVORITES) ??
                          List<String>();
                      list.add(widget.music.key);
                      widget.prefs
                          .setStringList(SharedPreferencesKeys.FAVORITES, list);
                      setState(() {});
                    },
                  ),
          ),
          tag: widget.music,
        ),
        Divider(height: 2),
      ],
    );
  }
}

class ItemTile extends StatelessWidget {
  final String title;
  final Function onTap;
  final IconData icon;
  final int count;

  const ItemTile({this.title, this.onTap, this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () => onTap(title),
          title: Text(title),
          leading: CircleAvatar(child: Icon(icon)),
          trailing: Badge(
            badgeColor: Colors.blueAccent,
            shape: BadgeShape.square,
            // borderRadius: 20,
            badgeContent: Text('$count', style: TextStyle(color: Colors.white)),
          ),
        ),
        Divider(height: 2)
      ],
    );
  }
}
