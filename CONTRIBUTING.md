# Contributing to RemoteOne

Thank you for contributing to **RemoteOne**! We welcome bug reports, feature requests, pull requests, and especially new device profiles for televisions and set-top boxes.

## Code of Conduct
Please be polite, constructive, and respectful to all contributors.

## How to Contribute

### 1. Contributing Device Profiles
The easiest way to contribute is by adding missing Indian cable/DTH or international TV brand profiles.
1. Check `device-profiles/schema/device_profile.schema.json`.
2. Add your profile in `device-profiles/tv/` or `device-profiles/set-top-box/`.
3. Validate your profile:
   ```bash
   pytest tests/test_profile_schema.py -v
   ```

### 2. Code Contributions
1. Fork the repository and create a feature branch (`git checkout -b feature/my-feature`).
2. Follow Dart and Python style conventions.
3. Run existing tests:
   ```bash
   pytest tests/ -v
   pytest backend/tests/ -v
   ```
4. Commit your changes with clear messages (`git commit -m "feat: Add Onida TV IR profile"`).
5. Push to your branch and open a Pull Request.

## Pull Request Guidelines
- Ensure all automated CI checks pass.
- Include unit tests for new protocol encoders or adapters.
- Never commit real user credentials, private keys, or API tokens.
