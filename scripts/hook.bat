@REM Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
@REM
@REM Licensed under the Apache License, Version 2.0 (the "License");
@REM you may not use this file except in compliance with the License.
@REM You may obtain a copy of the License at
@REM
@REM         http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing, software
@REM distributed under the License is distributed on an "AS IS" BASIS,
@REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@REM See the License for the specific language governing permissions and
@REM limitations under the License.

@REM Usage example: cmd.exe /C ./scripts/hook.bat
@echo off

echo Build specification:
echo    DefaultRepo:    %SKAFFOLD_DEFAULT_REPO%
echo    MultiLevelRepo: %SKAFFOLD_MULTI_LEVEL_REPO%
echo    RPCPort:        %SKAFFOLD_RPC_PORT%
echo    HTTPPort:       %SKAFFOLD_HTTP_PORT%
echo    WorkDir:        %SKAFFOLD_WORK_DIR%
echo    Image:          %SKAFFOLD_IMAGE%
echo    PushImage:      %SKAFFOLD_PUSH_IMAGE%
echo    ImageRepo:      %SKAFFOLD_IMAGE_REPO%
echo    ImageTag:       %SKAFFOLD_IMAGE_TAG%
echo    BuildContext:   %SKAFFOLD_BUILD_CONTEXT%
