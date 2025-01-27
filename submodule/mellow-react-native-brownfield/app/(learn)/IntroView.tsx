import React from "react";
import { View, Text, StyleSheet, Image, type ViewProps } from "react-native";

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
  return (
    <View style={[styles.container, style]} {...otherProps}>
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
