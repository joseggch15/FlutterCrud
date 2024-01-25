import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class User {
  final int id;
  final String username;
  final String password;
  final String email;
  final Role role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'role': role.toJson(),
    };
  }
}

class Role {
  final int id;
  final String roleName;
  final String roleDescription;

  Role({
    required this.id,
    required this.roleName,
    required this.roleDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleName': roleName,
      'roleDescription': roleDescription,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.get(
      Uri.parse('http://3.129.92.139:8080/api/user/all'),
    );

    if (response.statusCode == 200) {
      List<dynamic> usersData = jsonDecode(response.body);

      String userEmail = _emailController.text;
      String userPassword = _passwordController.text;

      bool userFound = false;
      Map<String, dynamic>? authenticatedUser;

      for (var userData in usersData) {
        if (userData['email'] == userEmail &&
            userData['password'] == userPassword) {
          userFound = true;
          authenticatedUser = userData;
          break;
        }
      }

      if (userFound) {
        if (authenticatedUser?['role'] != null &&
            authenticatedUser?['role']['roleName'] == 'Super user') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(authenticatedUser: authenticatedUser),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NonSuperUserScreen(),
            ),
          );
        }
      } else {
        print('Login failed: User not found or incorrect credentials');
      }
    } else {
      print('Login failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? authenticatedUser;

  HomeScreen({this.authenticatedUser});

  Future<void> _logout(BuildContext context) async {
    // Aquí puedes realizar cualquier lógica de cierre de sesión si es necesario.
    // Por ejemplo, limpiar el token de autenticación, eliminar datos de usuario, etc.
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://media.licdn.com/dms/image/C5103AQH7HMiCpF1pyw/profile-displayphoto-shrink_200_200/0/1517607989251?e=2147483647&v=beta&t=bJz8qXoft3mTkiTMAi6CjF1mYaCaQhRUKQoULSg1vSY',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    authenticatedUser?['username'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authenticatedUser?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Ayuda'),
              onTap: () {
                // Agrega aquí la lógica para la opción de Ayuda
              },
            ),
            ListTile(
              title: Text('Acerca de nosotros'),
              onTap: () {
                // Agrega aquí la lógica para la opción de Acerca de nosotros
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen!'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUserScreen()),
                );
              },
              child: Text('Create User'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewUsersScreen(
                          authenticatedUser: authenticatedUser)),
                );
              },
              child: Text('View Users'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'User';

Future<void> _createUser() async {
  int roleId;

  // Asigna el id del rol según la opción seleccionada
  switch (_selectedRole) {
    case 'User':
      roleId = 2;
      break;
    case 'Administrator':
      roleId = 1;
      break;
    case 'Super user':
      roleId = 3;
      break;
    default:
      // En caso de no coincidir con ninguna opción, asigna un valor predeterminado
      roleId = 2;
  }

  final user = User(
    id: 0,
    username: _usernameController.text,
    password: _passwordController.text,
    email: _emailController.text,
    role: Role(
      id: roleId,
      roleName: _selectedRole,
      roleDescription: '',
    ),
  );
    final response = await http.post(
      Uri.parse('http://3.129.92.139:8080/api/user/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      print('User created successfully');
    } else {
      print('Failed to create user. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              items: [
                {'label': 'User', 'id': 2},
                {'label': 'Administrator', 'id': 1},
                {'label': 'Super user', 'id': 3},
              ].map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                return DropdownMenuItem<String>(
                  value: item['label'],
                  child: Text(item['label']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _createUser,
              child: Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewUsersScreen extends StatefulWidget {
  final Map<String, dynamic>? authenticatedUser;

  ViewUsersScreen({this.authenticatedUser});

  @override
  _ViewUsersScreenState createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List<User> usersList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://3.129.92.139:8080/api/user/all'),
    );

    if (response.statusCode == 200) {
      List<dynamic> usersData = jsonDecode(response.body);
      setState(() {
        usersList = usersData
            .map((userData) => User(
                  id: userData['id'],
                  username: userData['username'],
                  password: userData['password'],
                  email: userData['email'],
                  role: Role(
                    id: userData['role']['id'],
                    roleName: userData['role']['roleName'],
                    roleDescription: userData['role']['roleDescription'],
                  ),
                ))
            .toList();
      });
    } else {
      print('Failed to fetch users. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Users'),
      ),
      body: ListView.builder(
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(usersList[index].username),
            subtitle: Text(usersList[index].email),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteUserScreen(
                      userToDelete: usersList[index],
                      authenticatedUser: widget.authenticatedUser),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DeleteUserScreen extends StatelessWidget {
  final User userToDelete;
  final Map<String, dynamic>? authenticatedUser;

  DeleteUserScreen({required this.userToDelete, this.authenticatedUser});

  Future<void> _deleteUser() async {
    if (authenticatedUser?['role'] != null &&
        authenticatedUser?['role']['roleName'] == 'Super user') {
      final response = await http.delete(
        Uri.parse('http://3.129.92.139:8080/api/user/${userToDelete.id}'),
      );

      if (response.statusCode == 200) {
        print('User deleted successfully');
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      print('Delete user failed: User does not have the required permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Are you sure you want to delete ${userToDelete.username}?'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _deleteUser,
              child: Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }
}

class NonSuperUserScreen extends StatelessWidget {
  final Map<String, dynamic>? authenticatedUser;
  final List<String> photos = []; // Agrega la lista de fotos aquí

  NonSuperUserScreen({this.authenticatedUser});

  Future<void> _logout(BuildContext context) async {
    // Aquí puedes realizar cualquier lógica de cierre de sesión si es necesario.
    // Por ejemplo, limpiar el token de autenticación, eliminar datos de usuario, etc.
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non-Super User Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://images.genius.com/babf22a596133c7057f5a895808caf45.720x720x1.jpg', // Agrega la URL de la imagen del usuario aquí
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    authenticatedUser?['username'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authenticatedUser?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Ayuda'),
              onTap: () {
                // Agrega aquí la lógica para la opción de Ayuda
              },
            ),
            ListTile(
              title: Text('Acerca de nosotros'),
              onTap: () {
                // Agrega aquí la lógica para la opción de Acerca de nosotros
              },
            ),
          ],
        ),
      ),
      body: _NonSuperUserScreen(photos: photos),
    );
  }
}

class _NonSuperUserScreen extends StatefulWidget {
  final List<String> photos;

  _NonSuperUserScreen({required this.photos});

  @override
  _NonSuperUserScreenState createState() => _NonSuperUserScreenState();
}

class _NonSuperUserScreenState extends State<_NonSuperUserScreen> {
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Agregar la ruta de la imagen a la lista de fotos
      setState(() {
        widget.photos.add(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome! You are Yuquero. Juepajee!'),
          ElevatedButton(
            onPressed: _takePhoto,
            child: Text('Take Photo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.file(File(widget.photos[index])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
