import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/garagem/view/garagem_screen.dart';
import 'features/garagem/view/veiculo_form_screen.dart';
import 'features/garagem/view/veiculo_detail_screen.dart';
import 'features/servicos/view/servicos_screen.dart';
import 'features/servicos/view/servico_form_screen.dart';
import 'features/abastecimentos/view/abastecimentos_screen.dart';
import 'features/abastecimentos/view/abastecimento_form_screen.dart';
import 'features/dashboard/view/dashboard_screen.dart';
import 'app_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const GaragemScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/veiculo/novo',
      builder: (context, state) => const VeiculoFormScreen(),
    ),
    GoRoute(
      path: '/veiculo/:id',
      builder: (context, state) => VeiculoDetailScreen(
        veiculoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/veiculo/:id/editar',
      builder: (context, state) => VeiculoFormScreen(
        veiculoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/veiculo/:id/servicos',
      builder: (context, state) => ServicosScreen(
        veiculoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/veiculo/:id/servicos/novo',
      builder: (context, state) {
        final veiculoId = int.parse(state.pathParameters['id']!);
        final servicoIdStr = state.uri.queryParameters['id'];
        return ServicoFormScreen(
          veiculoId: veiculoId,
          servicoId: servicoIdStr != null ? int.tryParse(servicoIdStr) : null,
        );
      },
    ),
    GoRoute(
      path: '/veiculo/:id/abastecimentos',
      builder: (context, state) => AbastecimentosScreen(
        veiculoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/veiculo/:id/abastecimentos/novo',
      builder: (context, state) {
        final veiculoId = int.parse(state.pathParameters['id']!);
        final aIdStr = state.uri.queryParameters['id'];
        return AbastecimentoFormScreen(
          veiculoId: veiculoId,
          abastecimentoId: aIdStr != null ? int.tryParse(aIdStr) : null,
        );
      },
    ),
  ],
);
