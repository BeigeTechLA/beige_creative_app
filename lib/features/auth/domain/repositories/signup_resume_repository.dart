import '../models/signup_step1_prefill.dart';

abstract class SignupResumeRepository {
  Future<SignupStep1Prefill> fetchStep1Prefill();
}
