# Expo Skills Orchestrator

Automatically select and apply the appropriate Expo skill based on task context. When working in an Expo project, read the relevant SKILL.md files from `./plugins/expo/skills/` before responding.

## Expo Project Detection

A project is an Expo project if any of the following are present:
- `package.json` contains `"expo"` in dependencies or devDependencies
- `app.json`, `app.config.js`, or `app.config.ts` exists at the project root
- `expo-router` or `expo-*` packages are listed in dependencies

## Skill Routing

### building-native-ui
**Activate when:** Building UI components, screens, navigation, layouts, animations, tabs, modals, sheets, headers, gestures, SF Symbols, or any visual styling with inline styles.
**Key signals:** `expo-router`, `Stack`, `NativeTabs`, `Reanimated`, `Gesture`, screen layout, navigation structure, component creation, styling.
**Skill path:** `./plugins/expo/skills/building-native-ui/SKILL.md`

### native-data-fetching
**Activate when:** Fetching data from APIs, managing server state, caching, offline support, React Query, Expo Router loaders.
**Key signals:** `useQuery`, `useMutation`, `fetch`, API integration, data caching, loading states, optimistic updates, network requests.
**Skill path:** `./plugins/expo/skills/native-data-fetching/SKILL.md`

### upgrading-expo
**Activate when:** Upgrading Expo SDK, migrating deprecated packages (`expo-av` to `expo-audio`/`expo-video`), fixing post-upgrade dependency conflicts, enabling New Architecture or React Compiler.
**Key signals:** `expo upgrade`, SDK version change, migration, deprecated package, New Architecture, React 19, React Compiler.
**Skill path:** `./plugins/expo/skills/upgrading-expo/SKILL.md`

### expo-tailwind-setup
**Activate when:** Setting up or configuring Tailwind CSS / NativeWind in an Expo project, or when the user asks about `className` on native components.
**Key signals:** `nativewind`, `tailwindcss`, `NativeWind`, Tailwind setup, `className` prop, `postcss.config`, `withNativewind`.
**Skill path:** `./plugins/expo/skills/expo-tailwind-setup/SKILL.md`

### expo-dev-client
**Activate when:** Creating development builds, distributing via TestFlight for development, setting up EAS Build for dev profiles, working with custom native modules.
**Key signals:** `expo-dev-client`, `developmentClient`, dev build, custom native code, local Expo module, Apple targets, dev distribution.
**Skill path:** `./plugins/expo/skills/expo-dev-client/SKILL.md`

### expo-deployment
**Activate when:** Submitting to App Store or Google Play, configuring EAS Build production profiles, TestFlight beta releases, web deployment with EAS Hosting, version management.
**Key signals:** `eas build`, `eas submit`, App Store Connect, Google Play Console, production build, release, submit, publish, store listing.
**Skill path:** `./plugins/expo/skills/expo-deployment/SKILL.md`

### expo-api-routes
**Activate when:** Creating or editing API routes within the Expo Router app directory.
**Key signals:** `+api.ts`, `+api.tsx`, server-side route handlers in `app/`, EAS Hosting API, `Request`, `Response` in Expo Router context.
**Skill path:** `./plugins/expo/skills/expo-api-routes/SKILL.md`

### expo-cicd-workflows
**Activate when:** Writing or configuring EAS CI/CD workflow YAML files for automated builds, deployments, or PR previews.
**Key signals:** `.eas/workflows/`, EAS Workflow YAML, automated deployment, PR preview, CI pipeline, `on: push`, `on: pull_request`.
**Skill path:** `./plugins/expo/skills/expo-cicd-workflows/SKILL.md`

## Multi-Skill Combinations

Some tasks require loading multiple skills simultaneously:

| Task | Skills to load |
|------|----------------|
| New app from scratch | building-native-ui + expo-tailwind-setup + native-data-fetching |
| Production release | expo-deployment + expo-cicd-workflows |
| SDK upgrade | upgrading-expo + building-native-ui |
| Dev build distribution | expo-dev-client + expo-deployment |
| Full-stack Expo app | building-native-ui + native-data-fetching + expo-api-routes |

## Instructions

1. Identify all relevant skills from the routing table above based on the user's request.
2. Read the SKILL.md file(s) for each matched skill before responding.
3. Apply the guidance from those skills throughout your response.
4. When in doubt, default to `building-native-ui` as the baseline for any Expo UI work.
