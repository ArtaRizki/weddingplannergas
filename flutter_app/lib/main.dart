import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'config/router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/guest_repository.dart';
import 'data/repositories/phase_repository.dart';
import 'data/repositories/rundown_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/vendor_repository.dart';
import 'domain/blocs/auth/auth_bloc.dart';
import 'domain/blocs/budget/budget_bloc.dart';
import 'domain/blocs/dashboard/dashboard_bloc.dart';
import 'domain/blocs/guest/guest_bloc.dart';
import 'domain/blocs/phase/phase_bloc.dart';
import 'domain/blocs/rundown/rundown_bloc.dart';
import 'domain/blocs/settings/settings_bloc.dart';
import 'domain/blocs/task/task_bloc.dart';
import 'domain/blocs/vendor/vendor_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const WeddingPlannerApp());
}

class WeddingPlannerApp extends StatefulWidget {
  const WeddingPlannerApp({super.key});

  @override
  State<WeddingPlannerApp> createState() => _WeddingPlannerAppState();
}

class _WeddingPlannerAppState extends State<WeddingPlannerApp> {
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _authBloc = AuthBloc(authRepository: _authRepository);

    // Check for stored token on app start
    _authBloc.add(const AuthCheckRequested());

    // Create router with auth-based redirect
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(
            dashboardRepository: DashboardRepository(),
          ),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => BudgetBloc(
            budgetRepository: BudgetRepository(),
          ),
        ),
        BlocProvider<GuestBloc>(
          create: (_) => GuestBloc(
            guestRepository: GuestRepository(),
          ),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: TaskRepository(),
          ),
        ),
        BlocProvider<PhaseBloc>(
          create: (_) => PhaseBloc(
            phaseRepository: PhaseRepository(),
          ),
        ),
        BlocProvider<VendorBloc>(
          create: (_) => VendorBloc(
            vendorRepository: VendorRepository(),
          ),
        ),
        BlocProvider<RundownBloc>(
          create: (_) => RundownBloc(
            rundownRepository: RundownRepository(),
          ),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(
            settingsRepository: SettingsRepository(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Wedding Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF69B4)),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
