# ayabar

`ayabar` — маленькая macOS status bar утилита с ANSI-кошкодевочкой.

## Что умеет
- дышит в статусбаре;
- машет лапками, когда нажимаются клавиши;
- следит за курсором (смотрит влево/вправо);
- раз в случайный промежуток времени крутится на месте;
- виляет хвостом между вдохами.

## Локальный запуск (macOS 13+)
```bash
swift run ayabar
```

## Сборка .app
```bash
./scripts/package_app.sh
open build/ayabar.app
```

## GitHub Actions
В репозитории добавлен workflow `.github/workflows/build-and-release.yml`:
- на каждом пуше в `main` собирает `.app` и загружает zip как artifact;
- на теге `v*` публикует релиз с `ayabar.app.zip` (первая версия: `v0.1.0`).

## Prebuilt в репозитории
После каждого пуша в `main` workflow обновляет `prebuilt/ayabar.app.zip`,
чтобы в репозитории всегда лежал готовый собранный `.app` в zip-формате.
