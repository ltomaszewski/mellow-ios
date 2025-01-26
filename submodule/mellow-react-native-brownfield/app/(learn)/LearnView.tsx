import React from "react";
import { View, Text, StyleSheet, ViewProps } from "react-native";

export type LearnViewProps = ViewProps & {
  route: {
    params: {
      course: string;
    };
  };
};

export default function LearnView({ route, ...otherProps }: LearnViewProps) {
  const { course } = route.params;

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Input: {course}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  text: {
    fontSize: 18,
  },
});
