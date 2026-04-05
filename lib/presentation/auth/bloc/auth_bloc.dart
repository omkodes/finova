import 'package:equatable/equatable.dart';
import 'package:finova/domain/entities/user_account.dart';
import 'package:finova/domain/repositories/i_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthSignUpRequested(this.email, this.password, this.name);
  @override
  List<Object> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthCompleteOnboardingRequested extends AuthEvent {
  final double startingBalance;
  final double monthlyBudget;
  const AuthCompleteOnboardingRequested(
    this.startingBalance,
    this.monthlyBudget,
  );
  @override
  List<Object> get props => [startingBalance, monthlyBudget];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final double? monthlyBudget;
  final String? profileImagePath;
  const AuthUpdateProfileRequested({
    this.name,
    this.monthlyBudget,
    this.profileImagePath,
  });
  @override
  List<Object> get props => [
    name ?? '',
    monthlyBudget ?? 0.0,
    profileImagePath ?? '',
  ];
}

class AuthDeleteAccountRequested extends AuthEvent {
  final String email;
  const AuthDeleteAccountRequested(this.email);
  @override
  List<Object> get props => [email];
}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserAccount user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthSignUpSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCompleteOnboardingRequested>(_onAuthCompleteOnboardingRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
  }

  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.deleteAccount(event.email);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to delete account: $e'));
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      emit(AuthLoading());
      try {
        final updatedUser = await authRepository.updateUserProfile(
          email: currentUser.email,
          name: event.name,
          monthlyBudget: event.monthlyBudget,
          profileImagePath: event.profileImagePath,
        );
        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        emit(AuthError('Failed to update profile: $e'));
        emit(AuthAuthenticated(currentUser)); // Revert to current user state
      }
    }
  }

  Future<void> _onAuthCompleteOnboardingRequested(
    AuthCompleteOnboardingRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      try {
        final updatedUser = await authRepository.completeOnboarding(
          currentUser.email,
          event.startingBalance,
          event.monthlyBudget,
        );
        emit(AuthAuthenticated(updatedUser)); // Reloads logic
      } catch (e) {
        emit(AuthError('Failed to save settings: $e'));
      }
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(event.email, event.password, event.name);
      emit(AuthSignUpSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
