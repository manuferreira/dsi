import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

// função principal
void main() => runApp(MyApp());

// classe que guarda as configurações do app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  //static const routeName = '/';

  // cria o estado da pagina RandomWords (pagina home)
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 16);


  // construção da página inicial (RandomWords)
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(icon: const Icon(Icons.list, color: Colors.lightBlue), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return Dismissible(
            key: ValueKey(_suggestions[index]),
            direction: DismissDirection.endToStart,
            child: _buildRow(_suggestions[index]),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (direction) {
              setState(() {
                _deleteItem(_suggestions[index]);
                _suggestions.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed'),
                backgroundColor: Colors.lightBlue));
            },
          );
        }
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: IconButton(
        icon: alreadySaved ? const Icon(Icons.favorite_rounded) : const Icon(Icons.favorite_border_rounded),
        color: alreadySaved ? Colors.lightBlue : null,
        onPressed: () {
          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        },
      ),
      onTap: () {
        _editWordPair(context, pair, _suggestions.indexOf(pair));
      },
    );
  }

  // tela de edição do par de palavras
  void _editWordPair(BuildContext context, WordPair pair, int index) {
    String? firstWord;
    String? secondWord;
    final formKey = GlobalKey<FormState>();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit pair')
            ),
            body: Container(
              color: Colors.black12,
              padding: EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: firstWord,
                      decoration: const InputDecoration(
                        hintText: 'Enter the first word',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'The field is empty, insert a new word';
                        }
                        return null;
                      },
                      onSaved: (value) => firstWord = value,
                    ),
                    TextFormField(
                      initialValue: secondWord,
                      decoration: const InputDecoration(
                        hintText: 'Enter the second word',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'The field is empty, insert a new word';
                        }
                        return null;
                      },
                      onSaved: (value) => secondWord = value,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            setState(() {
                              var pairUpdated = WordPair(firstWord!, secondWord!);
                              _suggestions.insert(index, pairUpdated);
                              Navigator.of(context).pop();
                            });
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text('Save changes')
                        )
                      ),
                ],
              )
            ),
          ));
        }
      )
    );
  }


  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  void _deleteItem(WordPair pair) {
    _saved.remove(pair);
  }

}


