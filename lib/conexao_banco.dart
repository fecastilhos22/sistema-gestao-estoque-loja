import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

/// Abre uma conexão com o banco Supabase usando a string do arquivo .env.
Future<Connection> abrirConexao() async {
  final env = DotEnv()..load();
  final url = Uri.parse(env['DATABASE_URL']!);
  final usuarioSenha = url.userInfo.split(':');

  return Connection.open(
    Endpoint(
      host: url.host,
      port: url.port,
      database: url.path.substring(1),
      username: Uri.decodeComponent(usuarioSenha[0]),
      password: Uri.decodeComponent(usuarioSenha[1]),
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );
}
