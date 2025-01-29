import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  Image,
  type ViewProps,
  EventSubscription,
} from "react-native";
// import NativeLocalStorage from "../../../../specs/NativeLocalStorage";
import NativeCalculator from "../../../../specs/NativeCalculator";

export type IntroViewProps = ViewProps & {
  image: string;
  text: string;
};

export default function IntroView({
  image,
  text,
  style,
  ...otherProps
}: IntroViewProps) {
  const [latestValue, setLatestValue] = useState<string>("");
  const listenerSubscription = React.useRef<null | EventSubscription>(null);

  useEffect(() => {
    // console.log(NativeLocalStorage);
    // const storedValue = NativeLocalStorage?.getItem("myKey");
    // console.log(storedValue);
    console.log(NativeCalculator?.getHelloMessage());
    NativeCalculator?.add(1, 2).then((result) => {
      console.log(result);
    });
    listenerSubscription.current = NativeCalculator.onValueChanged((data) => {
      setLatestValue(data?.toString() ?? "");
    });
    return () => {
      listenerSubscription.current?.remove();
      listenerSubscription.current = null;
    };
  }, []);

  return (
    <View style={[styles.container, style]} {...otherProps}>
      {/* Display the latest value above the image */}
      <Text style={styles.latestValueText}>Test: {latestValue}</Text>
      <Image source={image} style={styles.image} resizeMode="contain" />
      <Text style={styles.text}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: "center",
    // justifyContent: "center",
  },
  latestValueText: {
    marginBottom: 8,
    fontSize: 18,
    color: "white",
  },
  image: {
    width: 92,
    height: 92,
  },
  text: {
    paddingTop: 42,
    fontFamily: "GothamRnd-Medium",
    fontSize: 28,
    lineHeight: 36,
    marginBottom: 8,
    textAlign: "center",
    color: "white", // Added text color
  },
});
