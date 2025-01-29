import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";
import type { EventEmitter } from "react-native/Libraries/Types/CodegenTypes";

export interface Spec extends TurboModule {
  onCourseStarted(course: string): void;
  onCourseEnded(course: string): void;
  readonly onRestState: EventEmitter<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  "NativeLearnConnector"
) as Spec;
