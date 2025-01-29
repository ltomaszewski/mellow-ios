import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";
import type { EventEmitter } from "react-native/Libraries/Types/CodegenTypes";

export interface Spec extends TurboModule {
  getHelloMessage(): string | null;
  add(a: number, b: number): Promise<number>;
  readonly onValueChanged: EventEmitter<number>;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  "NativeCalculator"
) as Spec | null;
