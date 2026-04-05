import '../entities/challenge_entity.dart';

abstract class ChallengeRepository {
  Future<ChallengeEntity?> getActiveChallenge();
  Future<void> startChallenge(ChallengeEntity challenge);
  Future<void> updateChallenge(ChallengeEntity challenge);
  Future<void> stopChallenge(int id);
}
